create table items (
   item varchar(25),
   unitWeight decimal(10,3),
   primary key(item)
);

create table busEntities (
   entity varchar(25),
   shipLoc varchar(25),
   address varchar(25),
   phone decimal(10,3),
   web varchar(100),
   contact decimal(20,3),
   primary key(entity)
);

create table billOfMaterials(
prodItem varchar(25),
matItem varchar(25),
QtyMatPerItem decimal(10,3),
primary key(prodItem, matItem),
foreign key(prodItem) references items(item),
foreign key(matItem) references items(item)
);

create table supplierDiscounts
(supplier varchar(25),
amt1 decimal(10,3),
disc1 decimal(3,3),
amt2 decimal(10,3),
disc2 decimal(3,3),
primary key(supplier));

create table supplyUnitPricing(supplier varchar(25),
item varchar(25),
ppu decimal(10,3),
primary key(supplier,item),
foreign key(item) references items(item));

create table manufDiscounts(
manuf varchar(25),
amt1 decimal(10,3),
disc1 decimal(3,3),
primary key(manuf));

create table manufUnitPricing
(manuf varchar(25),
prodItem varchar(25),
setUpCost decimal(10,3),
prodCostPerUnit decimal(10,3),
primary key(manuf,prodItem),
foreign key(prodItem) references items(item)
);

create table shippingPricing(
shipper varchar(25),
fromLoc  varchar(25),
toLoc varchar(25),
minPackagePrice decimal(10,3),
pricePerLb decimal(10,3),
amt1 decimal(10,3),
disc1 decimal(3,3),
amt2 decimal(10,3),
disc2 decimal(3,3),
primary key (shipper, fromLoc, toLoc));

create table customerDemand(
customer varchar(25),
item varchar(25),
qty decimal(10,3),
primary key(customer, item),
foreign key(item) references items(item),
foreign key(customer) references busEntities(entity)
 );

create table supplyOrders(
item varchar(25),
supplier varchar(25),
qty decimal(10,3),
primary key(item, supplier),
foreign key(item) references items(item),
foreign key(supplier) references busEntities(entity)
);

create table manufOrders(
item varchar(25),
manuf varchar(25),
qty decimal(10,3),
primary key(item, manuf),
foreign key(item) references items(item),
foreign key(manuf) references busEntities(entity));


create table shipOrders(
item varchar(25),
shipper varchar(25),
sender varchar(25),
recipient varchar(25),
qty decimal(10,3),
primary key(item, shipper, sender, recipient),
foreign key(shipper) references busEntities(entity),
foreign key(item) references items(item),
foreign key(sender) references busEntities(entity),
foreign key(recipient) references busEntities(entity));
