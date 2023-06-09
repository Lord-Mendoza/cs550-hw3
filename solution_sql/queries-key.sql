-- Lord Mendoza - G00841164
-- CS 550 - DB Project - Part 2

-- Query 1: Done
create view shippedVSCustDemand as
select c.customer as customer, c.item as item, sum(IFNULL(s.qty, 0)) as suppliedQty, c.qty as demandQty
from customerDemand c
         left join shipOrders s on
            c.item = s.item
        and c.customer = s.recipient
group by c.customer, c.item, c.qty
order by c.customer, c.item;

-- Query 2: Done
create view totalManufItems as
select item as item, sum(qty) as totalManufQty
from manufOrders
group by item
order by item;

-- Query 3: Done
create view matsUsedVsShipped as
select r.manuf, r.matItem, r.reqQty as requiredQty, IFNULL(sum(s.qty), 0) as shippedQty
from (select m.manuf, b.matItem, sum(m.qty * b.QtyMatPerItem) as reqQty
      from manufOrders m,
           billOfMaterials b
      where m.item = b.prodItem
      group by m.manuf, b.matItem) r
         left join shipOrders s on s.recipient = r.manuf and s.item = r.matItem
group by r.manuf, r.matItem, r.reqQty
order by r.manuf, r.matItem;

-- Query 4: Done
create view producedVsShipped as
select m.item, m.manuf, IFNULL(sum(s.qty), 0) as shippedOutQty, m.qty as orderedQty
from manufOrders m
         left join shipOrders s on s.item = m.item and s.sender = m.manuf
group by m.item, m.manuf, m.qty
order by m.item, m.manuf;

-- Query 5: Done
create view suppliedVsShipped as
select s.item, s.supplier, s.qty as suppliedQty, IFNULL(sum(s1.qty), 0) as shippedQty
from supplyOrders s
         left join shipOrders s1 on s1.item = s.item and s1.sender = s.supplier
group by s.item, s.supplier
order by s.item, s.supplier;

-- Query 6: DONEEE
-- similar to query 7
create view totalSupplyCostPerSupplier as
select o.supplier,
       #supply base cost = prodPricePerUnit (ppu) times qty of supply item
       IFNULL(sum(o.qty * u.ppu), 0) as supplyCost
from supplyOrders o,
     supplyUnitPricing u
where o.supplier = u.supplier
  and o.item = u.item
group by o.supplier;

create view perSupplierCost as
select d.supplier,
       IFNULL(
           case
               #discounted -- in excess of amt2 -- need to combine discount from amt1 and amt2 since separate
               when s.supplyCost > d.amt2 then (
                   #amt1 discount
                   ((d.amt2 - d.amt1)             #cost difference between amt2 and amt1 to give disc1
                       * (1 - d.disc1))           #discounted supply cost for what's covered in amt1
                       + d.amt1)                  #add non-discounted cost for total

                   +

                   #amt2 discount
                   ((s.supplyCost - d.amt2)      #supplyCost cost excess of amt2
                        * (1 - d.disc2)          #discounted supply cost for what's covered in amt2
               )

               #discounted -- within amt1 and amt2 -- only apply amt1 discount
               when s.supplyCost > d.amt1 and s.supplyCost < d.amt2 then (
                   #amt1 discount
                   ((s.supplyCost - d.amt1)      #supplyCost cost excess of amt1
                       * (1 - d.disc1))          #discounted supply cost for what's covered in amt1
                       + d.amt1                  #add non-discounted cost for total
               )

               #no discount
               when s.supplyCost < d.amt1 then s.supplyCost
           end
       , 0) as cost
from totalSupplyCostPerSupplier s
         right join supplierDiscounts d on d.supplier = s.supplier
order by d.supplier;

-- Query 7: DONE
create view totalManufacturingCostPerManufacturer as
select o.manuf,
       # 'manufacturer base cost = setUpCost + prodPricePerUnit times qty of produced prodItem'
       IFNULL(sum(u.setUpCost + (u.prodCostPerUnit * o.qty)), 0) as manufacturingCost
from manufOrders o,
     manufUnitPricing u
where o.item = u.prodItem
  and o.manuf = u.manuf
group by o.manuf;

create view perManufCost as
select d.manuf,
       IFNULL(
           case
                #discounted -- base manufacturingCost + discountedManufacturingCost
                when t.manufacturingCost > d.amt1 then
                    ((t.manufacturingCost - d.amt1)      #'manufacturing cost excess of amt1'
                    * (1 - d.disc1))                     #discounted manufacturing cost
                    + d.amt1                             #add non-discounted cost for total

               #not discounted
               when t.manufacturingCost < d.amt1 then t.manufacturingCost
           end
       , 0) as cost
from totalManufacturingCostPerManufacturer t
         right join manufDiscounts d on d.manuf = t.manuf
order by d.manuf;

-- Query 8: DONEEE
-- similar to query 6
create view totalShippingCostPerToFromLocation as
select s.shipper,
       b1.shipLoc                                          as fromLocation,
       b2.shipLoc                                          as toLocation,
       IFNULL(sum(i.unitWeight * s.qty * p.pricePerLb), 0) as shippingCost
from shipOrders s,
     shippingPricing p,
     items i,
     busEntities b1,
     busEntities b2
where s.shipper = p.shipper
  and s.item = i.item
  and b1.entity = s.sender
  and b2.entity = s.recipient
  and b1.shipLoc = p.fromLoc
  and b2.shipLoc = p.toLoc
group by s.shipper, b1.shipLoc, b2.shipLoc;

create view perShipperCost as
select s.shipper,
       #need to take 'maximum of s.minPackagePrice and the discounted price'
       IFNULL(sum(greatest(
          case
              #discounted -- in excess of amt2 -- need to combine discount from amt1 and amt2 since separate
              when t.shippingCost > s.amt2 then (
                   #amt1 discount
                   ((s.amt2 - s.amt1)             #cost difference between amt2 and amt1 to give disc1
                       * (1 - s.disc1))           #discounted shipping cost for what's covered in amt1
                       + s.amt1)                  #add non-discounted cost for total

                   +

                   #amt2 discount
                   ((t.shippingCost - s.amt2)      #shipping cost excess of amt2
                        * (1 - s.disc2)            #discounted shipping cost for what's covered in amt2
              )

              #discounted -- within amt1 and amt2 -- only apply amt1 discount
              when t.shippingCost > s.amt1 and t.shippingCost < s.amt2 then (
                   #amt1 discount
                   ((t.shippingCost - s.amt1)      #supplyCost cost excess of amt1
                      * (1 - s.disc1))           #discounted supply cost for what's covered in amt1
                      + s.amt1                   #add non-discounted cost for total
              )

              #no discount
              when t.shippingCost < s.amt1 then t.shippingCost
          end, s.minPackagePrice))
       , 0) as cost
from totalShippingCostPerToFromLocation t
            right join shippingPricing s on s.shipper = t.shipper and s.fromLoc = t.fromLocation and s.toLoc = t.toLocation
group by s.shipper
order by s.shipper;

-- Query 9:
-- combines query 6, 7, 8 to get total cost breakdown
create view totalCostBreakDown as
select sp.cost as supplyCost, m.cost as manufCost, sh.cost as shippingCost, (sp.cost + m.cost + sh.cost) as totalCost
from (select sum(cost) as cost from perSupplierCost) sp,
     (select sum(cost) as cost from perManufCost) m,
     (select sum(cost) as cost from perShipperCost) sh;

-- Query 10: DONE
create view receivedQtyByCustomer as
select c.customer, c.item, IFNULL(sum(s.qty), 0) as received
from customerDemand c
         left join shipOrders s on s.recipient = c.customer and s.item = c.item
group by c.customer, c.item;

create view customersWithUnsatisfiedDemand as
select distinct r.customer
from receivedQtyByCustomer r,
     customerDemand c
where r.customer = c.customer
  and r.item = c.item
  and r.received < c.qty
ORDER BY r.customer;

-- Query 11: Done
create view suppliersWithUnsentOrders as
select distinct s.supplier
from supplyOrders s,
     (select s1.supplier, s1.item, IFNULL(sum(s2.qty), 0) as sentQty
      from supplyOrders s1
               left join shipOrders s2 on s2.sender = s1.supplier and s1.item = s2.item
      group by s1.supplier, s1.item) temp
where s.supplier = temp.supplier
  and s.item = temp.item
  and s.qty > temp.sentQty
order by s.supplier;

-- Query 12: DONE
create view neededQtyByManuf as
select m.manuf, b.matItem, IFNULL(sum(m.qty * b.QtyMatPerItem), 0) as needed
from manufOrders m,
     billOfMaterials b
where m.item = b.prodItem
group by m.manuf, b.matItem;

create view receivedQtyByManuf as
select n.manuf, n.matItem, IFNULL(sum(distinct s.qty), 0) as received
from neededQtyByManuf n
         left join shipOrders s on s.item = n.matItem and s.recipient = n.manuf
group by n.manuf, n.matItem;

create view manufsWoutEnoughMats as
select distinct n.manuf
from neededQtyByManuf n,
     receivedQtyByManuf r
where n.manuf = r.manuf
  and n.matItem = r.matItem
  and n.needed > r.received
ORDER by n.manuf;

-- Query 13: Done
-- similar to query 11
create view manufsWithUnsentOrders as
select distinct m.manuf
from manufOrders m,
     (select m1.manuf, m1.item, IFNULL(sum(s.qty), 0) as sentQty
      from manufOrders m1
               left join shipOrders s on s.sender = m1.manuf and m1.item = s.item
      group by m1.manuf, m1.item) temp
where m.manuf = temp.manuf
  and m.item = temp.item
  and m.qty > temp.sentQty
order by m.manuf;