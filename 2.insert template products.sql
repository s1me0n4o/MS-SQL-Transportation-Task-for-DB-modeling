
insert into trn.t_wrh(nme, wrh_adr, wrh_long, wrh_lat, cre_dat, cre_by, upd_dat, upd_by)
values
('WH1', 'Stara Zagora', 23.3, 42.6, getdate(),'S.Vasilev', getdate(),'S.Vasilev'),
('WH2', 'Sofia', 25.6, 42.4, getdate(),'S.Vasilev', getdate(),'S.Vasilev')
GO

insert into trn.t_tpl_prd (dsc, ord, wrh_id, cre_by, cre_dat, upd_by, upd_dat)
values
('Product 1',1,1, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 2',2,1, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 3',3,1, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 4',4,1, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 5',5,1, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 6',6,1, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 7',7,1, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 8',8,2, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 9',9,2, 'S.Vasilev', getdate(),'S.Vasilev', getdate()),
('Product 10',10,2, 'S.Vasilev', getdate(),'S.Vasilev', getdate())
go

insert into trn.t_veh_typ (dsc, cre_dat, cre_by, upd_dat, upd_by)
values
('car',getdate(),'S.Vasilev', getdate(),'S.Vasilev'),
('truck',getdate(),'S.Vasilev', getdate(),'S.Vasilev'),
('electric car',getdate(),'S.Vasilev', getdate(),'S.Vasilev')
go
insert into trn.t_veh_spec (brd, mdl, flu_con_per_100_km, cre_dat, cre_by, upd_dat, upd_by)
values
('Audi', 'A6', 15,getdate(),'S.Vasilev', getdate(),'S.Vasilev'),
('BMW', '530', 15,getdate(),'S.Vasilev', getdate(),'S.Vasilev'),
('Mercedes', 'Actos', 30,getdate(),'S.Vasilev', getdate(),'S.Vasilev')
go
insert into trn.t_veh (typ_id, spec_id, reg, cre_dat, cre_by, upd_dat, upd_by)
values
(1,1,'CA1451CT', getdate(),'S.Vasilev', getdate(),'S.Vasilev'),
(1,2,'CT5352AP', getdate(),'S.Vasilev', getdate(),'S.Vasilev'),
(2,3,'CT5352AP', getdate(),'S.Vasilev', getdate(),'S.Vasilev')
go


