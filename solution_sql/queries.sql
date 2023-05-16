-- Query 1
create view shippedVSCustDemand as
select c.customer as customer, c.item as item, IFNULL(SUM(s.qty), 0) as suppliedQty, c.qty as demandQty
from customerDemand c
    left join shipOrders s on c.item = s.item and c.customer = s.recipient
group by c.customer, c.item, c.qty
order by customer, item;

-- Query 2
create view totalManufItems as
select m.item as item, IFNULL(SUM(m.qty), 0) as totalManufQty
from manufOrders m
group by m.item
order by item;

-- Query 3
create view matItemQtyNeeded as
select m.manuf, b.matItem, IFNULL(SUM(m.qty * b.QtyMatPerItem), 0) as needed
from manufOrders m
    left join billOfMaterials b on m.item = b.prodItem
group by m.manuf, b.matItem;

create view matsUsedVsShipped as
select m.manuf as manuf, m.matItem as matItem, m.needed as requiredQty, IFNULL(SUM(s.qty), 0) as shippedQty
from matItemQtyNeeded m
    left join shipOrders s on m.manuf = s.recipient and m.matItem = s.item
group by m.manuf, m.matItem, m.needed
order by manuf, matItem;

-- Query 4
create view producedVsShipped as
select m.item as item, m.manuf as manuf, IFNULL(SUM(s.qty), 0) as shippedOutQty, m.qty as orderedQty
from manufOrders m
    left join shipOrders s on m.item = s.item and m.manuf = s.sender
group by m.item, m.manuf, m.qty
order by item, manuf;

-- Query 5
create view suppliedVsShipped as
select supOrd.item as item, supOrd.supplier as supplier, supOrd.qty as suppliedQty, IFNULL(SUM(shipOrd.qty), 0) as shippedQty
from supplyOrders supOrd
    left join shipOrders shipOrd on supOrd.item = shipOrd.item and supOrd.supplier = shipOrd.sender
group by supOrd.item, supOrd.supplier, supOrd.qty
order by item, supplier;

-- Query 6

create view totalCostPerItemPerSupplier as
select s.supplier, IFNULL(SUM(s.qty * p.ppu), 0) as cost
from supplyOrders s
    left join supplyUnitPricing p on s.supplier = p.supplier and s.item = p.item
group by s.supplier;

-- already have total amount so sum() doesn't need to be done only need to apply the discounts.
create view perSupplierCost as
select s.supplier as supplier, IFNULL(
        (CASE
            WHEN (t.cost > s.amt2)
            THEN (
                ((t.cost - s.amt2) * (1 - s.disc2))
                +
                ((s.amt2 - s.amt1) * (1 - s.disc1))
                +
                (s.amt1)
            )

            WHEN (t.cost < s.amt2 and t.cost > s.amt1)
            THEN (
                ((t.cost - s.amt1) * (1 - s.disc1))
                +
                (s.amt1)
            )

            WHEN (t.cost < s.amt1)
            THEN (t.cost)
        END)
    , 0) as cost
from supplierDiscounts s
    left join totalCostPerItemPerSupplier t on s.supplier = t.supplier
order by supplier;

-- Query 7
create view totalCostPerItemPerManuf as
select m.manuf, IFNULL(SUM((m.qty * p.prodCostPerUnit) + p.setUpCost), 0) as cost
from manufOrders m
    left join manufUnitPricing p on m.manuf = p.manuf and m.item = p.prodItem
group by m.manuf;

create view perManufCost as
select m.manuf as manuf, IFNULL(
        (CASE
            WHEN (t.cost > m.amt1)
            THEN (
                ((t.cost - m.amt1) * (1 - m.disc1))
                +
                (m.amt1)
            )

            WHEN (t.cost < m.amt1)
            THEN (
                (t.cost)
            )
        END)
    , 0) as cost
from manufDiscounts m
    left join totalCostPerItemPerManuf t on m.manuf = t.manuf
order by manuf;

-- Query 8
-- note that sender/recipient would correspond to busEntities.entity
-- and shippingPricing.fromLoc/.toLoc correspond to busEntities.shipLoc

create view perItemPerToFromPerShipper as
select s.shipper,
       b1.shipLoc                                          as fromLoc,
       b2.shipLoc                                          as toLoc,
       IFNULL(SUM(i.unitWeight * p.pricePerLb * s.qty), 0) as cost
from shipOrders s,
     shippingPricing p,
     items i,
     busEntities b1,
     busEntities b2
where s.shipper = p.shipper
  and s.item = i.item
  and s.sender = b1.entity
  and s.recipient = b2.entity
  and p.fromLoc = b1.shipLoc
  and p.toLoc = b2.shipLoc
group by s.shipper, b1.shipLoc, b2.shipLoc;

-- use greatest() vs. max() to get the greater of two values
-- need to take the sum since minPackagePrice is a minimum value, and want to accumulate
-- it as part of the sum of discounted cost (if any).
create view perShipperCost as
select s.shipper as shipper, IFNULL(
        sum(
        greatest(
            (CASE
                WHEN (p.cost > s.amt2)
                THEN (
                    ((p.cost - s.amt2) * (1 - s.disc2))
                    +
                    ((s.amt2 - s.amt1) * (1 - s.disc1))
                    +
                    (s.amt1)
                )

                WHEN (p.cost < s.amt2 and p.cost > s.amt1)
                THEN (
                    ((p.cost - s.amt1) * (1 - s.disc1))
                    +
                    (s.amt1)
                )

                WHEN (p.cost < s.amt1)
                THEN (p.cost)
            END)
    , s.minPackagePrice))
    , 0) as cost
from shippingPricing s
    left join perItemPerToFromPerShipper p on s.shipper = p.shipper and s.fromLoc = p.fromLoc and s.toLoc = p.toLoc
group by s.shipper
order by shipper;

-- Query 9
-- note to not just take the cost, but to sum all the cost for each table together

create view totalCostBreakDown as
select sup.cost as supplyCost, man.cost as manufCost, ship.cost as shippingCost, IFNULL((sup.cost + man.cost + ship.cost), 0) as totalCost
from (select sum(cost) as cost from perSupplierCost) sup,
     (select sum(cost) as cost from perManufCost) man,
     (select sum(cost) as cost from perShipperCost) ship;

-- Query 10
create view customersWithUnsatisfiedDemand as
select distinct s1.customer as customer
from shippedVSCustDemand s1,
     shippedVSCustDemand s2
where s1.item = s2.item
and s1.customer = s2.customer
and s1.demandQty > s2.suppliedQty
order by customer;

-- Query 11
create view suppliersWithUnsentOrders as
select distinct s1.supplier as supplier
from suppliedVsShipped s1,
     suppliedVsShipped s2
where s1.item = s2.item
and s1.supplier = s2.supplier
and s1.suppliedQty > s2.shippedQty
order by supplier;

-- Query 12
create view manufsWoutEnoughMats as
select distinct m1.manuf as manuf
from matsUsedVsShipped m1,
     matsUsedVsShipped m2
where m1.manuf = m2.manuf
and m1.matItem = m2.matItem
and m1.requiredQty > m2.shippedQty
order by manuf;

-- Query 13
create view manufsWithUnsentOrders as
select distinct p1.manuf as manuf
from producedVsShipped p1,
     producedVsShipped p2
where p1.manuf = p2.manuf
and p1.item = p2.item
and p1.orderedQty > p2.shippedOutQty
order by manuf;
