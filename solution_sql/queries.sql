-- Query 1

create view shippedVSCustDemand as
select c.customer as customer, s.item as item, s.qty as suppliedQty, c.qty as demandQty
from customerDemand c, shipOrders s
where c.customer = s.recipient
and c.item = s.item
order by c.customer, c.item;


-- Query 2

create view totalManufItems as 
	select item as item, COUNT(qty) as totalManufQty
    from manufOrders
    group by manuf
    order by item;


-- Query 3
create view matsUsedVsShipped as
select m.manuf as manuf , b.matItem as matItem, m.qty as requiredQty, s.qty as shippedQty
from manufOrders m, billOfMaterials b, shipOrders s
where m.item = b.prodItem
  and b.prodItem = s.item
group by m.manuf
order by m.manuf, b.prodItem;


-- Query 4
# create view producedVsShipped as
# 	select	__ as item, __ as manuf, __ as shippedOutQty, __ as  orderedQty
# 	from
# 		;


-- Query 5
# create view suppliedVsShipped as
# 	select	__ as item, __ as supplier, __ as suppliedQty, __ as shippedQty
# 	from
# 		;


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


-- Query 9
create view totalCostBreakDown as
select supplyCost, manufCost, shippingCost, SUM(supplyCost + manufCost + shippingCost) as totalCost
from (
    select SUM(ppu) as supplyCost
     from supplyUnitPricing
    UNION
    select SUM(setUpCost + prodCostPerUnit) as manufCost
     from manufUnitPricing
    UNION
    select MAX(minPackagePrice) as shippingCost
    from shippingPricing
) t;


-- Query 10
create view customersWithUnsatisfiedDemand as
select c.customer as customer
from customerDemand c
where c.item not in (
    select item
    from shipOrders s
    where c.customer = s.recipient
)
ORDER BY c.customer;


-- Query 11
create view suppliersWithUnsentOrders as
select s1.supplier as supplier
from supplyOrders s1
where s1.item not in (
    select item
    from shipOrders s2
    where s1.supplier = s2.recipient
)
ORDER BY s1.supplier;


-- Query 12
create view manufsWoutEnoughMats as
select m.manuf as manuf
from manufOrders m, shipOrders s
where m.manuf = s.recipient and m.qty < s.qty
ORDER by m.manuf;

-- Query 13
create view manufsWithUnsentOrders as
select m.manuf as manuf
from manufOrders m
where m.item not in (
    select item
    from shipOrders s
    where m.manuf = s.recipient
)
ORDER BY m.manuf;
