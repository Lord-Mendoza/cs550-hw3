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

# -- Query 4
# create view producedVsShipped as
# select __ as item, __ as manuf, __ as shippedOutQty, __ as orderedQty
# from
# ;
#
#
# -- Query 5
# create view suppliedVsShipped as
# select __ as item, __ as supplier, __ as suppliedQty, __ as shippedQty
# from
# ;
#
#
# -- Query 6
# create view perSupplierCost as
# select __ as supplier, __ as cost
# from
# ;
#
#
# -- Query 7
# create view perManufCost as
# select __ as manuf, __ as cost
# from
# ;
#
#
# -- Query 8
# create view perShipperCost as
# select __ as shipper, __ as cost
# from
# ;
#
#
# -- Query 9
# create view totalCostBreakDown as
# select __ as supplyCost, __ as manufCost, __ as shippingCost, __ as totalCost
# from
# ;
#
#
# -- Query 10
# create view customersWithUnsatisfiedDemand as
# select __ as customer
# from
# ;
#
#
# -- Query 11
# create view suppliersWithUnsentOrders as
# select __ as supplier
# from
# ;
#
#
# -- Query 12
# create view manufsWoutEnoughMats as
# select __ as manuf
# from
# ;
#
# -- Query 13
# create view manufsWithUnsentOrders as
# select __ as manuf
# from
# ;
