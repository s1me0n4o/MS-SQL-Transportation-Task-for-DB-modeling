

create schema trn -- transportation
go

create table trn.t_cus
(
	id int primary key identity(1,1),
	fnm varchar(50) not null,
	snm varchar(50) not null,
	cln_cmp_typ bit not null default 0, -- 0 for company // 1 for client
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null
)
go

create table trn.t_adr
(
	id int primary key identity(1,1),
	cus_id int not null,
	adr varchar(75) not null,
	city varchar(75) not null,
	lat decimal(9,1) not null,
	long decimal(9,1) not null,
	country varchar(20) not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null
	foreign key (cus_id) references trn.t_cus(id)
)
go

create table trn.t_wrh
(
	id int primary key identity(1,1),
	nme varchar(50) not null,
	wrh_adr varchar(150) not null,
	wrh_long decimal(9,1) not null,
	wrh_lat decimal(9,2) not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null,
)
go



create table trn.t_veh_typ
(
	id int primary key identity(1,1),
	dsc varchar(30) not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null
)
go

create table trn.t_veh_spec
(
	id int primary key identity(1,1),
	brd varchar(30) not null,
	mdl varchar(30) not null,
	flu_con_per_100_km decimal(9,2) not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null
)
go

create table trn.t_veh
(
	id int primary key identity(1,1),
	typ_id int not null,
	spec_id int not null,
	reg varchar(15) not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null,
	foreign key (typ_id) references trn.t_veh_typ(id),
	foreign key (spec_id) references trn.t_veh_spec(id)
)
go
create table trn.t_emp
(
	id int primary key identity(1,1),
	fnm varchar(50) not null,
	snm varchar(50) not null,
	wrh_id int not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null,
	foreign key (wrh_id) references trn.t_wrh(id)
)
go

create table trn.t_ship
(
	id int primary key identity,
	wrh_id int not null,
	veh_id int not null,
	drv_id int null,
	drv_nme varchar(100) not null,
	bgn_pnt varchar(150) not null,
	end_pnt varchar(150) not null,
	sta_dat smalldatetime not null,
	end_dat smalldatetime not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null
	foreign key (wrh_id) references trn.t_wrh(id),
	foreign key (veh_id) references trn.t_veh(id),
	foreign key (drv_id) references trn.t_emp(id)
)
go

create table trn.t_ship_leg
(
	id int primary key identity(1,1),
	ship_id int not null,
	leg_adr varchar(150),
	leg_lat decimal(9,1),
	leg_long decimal(9,1),
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null,
	foreign key (ship_id) references trn.t_ship(id),
)
go

create table trn.t_ord
(
	id int primary key identity(1,1),
	cus_id int not null,
	ship_id int null,
	dsc varchar(50) not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null
	foreign key (cus_id) references trn.t_cus(id),
	foreign key (ship_id) references trn.t_ship(id),
)
go


create table trn.t_tpl_prd
(
	id int primary key identity(1,1),
	dsc varchar(50) not null,
	wrh_id int not null,
	ord tinyint not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null,
	foreign key (wrh_id) references trn.t_wrh(id)
)
go

create table trn.t_prd
(
	id int primary key identity(1,1),
	prd_id int not null,
	ord_id int not null,
	wrh_id int not null,
	dsc varchar(50) not null,
	avl bit not null default 1,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null
	foreign key (ord_id) references trn.t_ord(id),
	foreign key (prd_id) references trn.t_tpl_prd(id)
)
go

create table trn.t_rtn_prd
(
	id int primary key identity(1,1),
	prd_id int not null,
	rsn varchar(500) not null,
	cre_dat smalldatetime not null,
	cre_by varchar(50) not null,
	upd_dat smalldatetime not null,
	upd_by varchar(50) not null,
	foreign key (prd_id) references trn.t_prd(id)
)
go

