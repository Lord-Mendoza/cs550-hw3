-- Query 1
create view shippedVSCustDemand as
select c.customer as customer, c.item as item, sum(IFNULL(s.qty, 0)) as suppliedQty, c.qty as demandQty
from customerDemand c
         left join shipOrders s on
            c.item = s.item
        and c.customer = s.recipient
group by c.customer, c.item, c.qty
order by c.customer, c.item;

-- Query 2
create view totalManufItems as
select item as item, sum(qty) as totalManufQty
from manufOrders
group by item
order by item;

-- Query 3
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

-- Query 4
create view producedVsShipped as
select m.item, m.manuf, IFNULL(sum(s.qty), 0) as shippedOutQty, m.qty as orderedQty
from manufOrders m
         left join shipOrders s on s.item = m.item and s.sender = m.manuf
group by m.item, m.manuf, m.qty
order by m.item, m.manuf;

-- Query 5
create view suppliedVsShipped as
select s.item, s.supplier, s.qty as suppliedQty, IFNULL(sum(s1.qty), 0) as shippedQty
from supplyOrders s
         left join shipOrders s1 on s1.item = s.item and s1.sender = s.supplier
group by s.item, s.supplier
order by s.item, s.supplier;

-- Query 6
# create view perSupplierCost as
# 	select	__ as supplier, __ as cost
# 	from
# 		;


-- Query 7
# create view perManufCost as
# 	select	__ as manuf, __ as cost
# 	from
# 		;


-- Query 8
# create view perShipperCost as
# 	select __ as shipper, __ as cost
# 	from
# 		;


-- Query 9: TODO: Need to do query 6, 7, 8
# create view totalCostBreakDown as
# select t.supplyCost, t.manufCost, t.shippingCost, SUM(t.supplyCost + t.manufCost + t.shippingCost) as totalCost
# from (select SUM(p1.cost) as supplyCost
#       from perSupplierCost p1
#       UNION
#       select SUM(p2.cost) as manufCost
#       from perManufCost p2
#       UNION
#       select SUM(p3.cost) as shippingCost
#       from perShipperCost p3) t;


-- Query 10
create view customersWithUnsatisfiedDemand as
select c.customer as customer
from customerDemand c
where c.item not in (select item
                     from shipOrders s
                     where c.customer = s.recipient)
ORDER BY c.customer;


-- Query 11
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


-- Query 12
create view manufsWoutEnoughMats as
select m.manuf as manuf
from manufOrders m,
     shipOrders s
where m.manuf = s.recipient
  and m.qty < s.qty
ORDER by m.manuf;

-- Query 13
create view manufsWithUnsentOrders as
select m.manuf as manuf
from manufOrders m
where m.item not in (select item
                     from shipOrders s
                     where m.manuf = s.recipient)
ORDER BY m.manuf;
