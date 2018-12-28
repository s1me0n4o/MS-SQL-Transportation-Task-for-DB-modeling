create or alter proc trn.s_delivery_speed
	@p_avg_spd int = 120
as
begin try
set nocount on

--declare @p_avg_spd int = 120 --average speed 120 km/h

begin try drop table #t_cnr end try begin catch end catch
begin try drop table #t_dta end try begin catch end catch


create table #t_dta
(
	cus_nme varchar(50),
	dlv_spd_in_hours int,
	city varchar(75),
	country varchar(75),
	veh varchar(50),
	veh_typ varchar(10)
)

create table #t_cnr
(
	cus_nme varchar(50),
	cus_lat decimal(9,1),
	cus_long decimal(9,1),
	wrh_lat decimal(9,1),
	wrh_long decimal(9,1),
	distance_wo_legs decimal(9,1),
	distance_frm_sta_to_leg decimal(9,1),
	distance_from_end_to_leg decimal(9,2),
	bgn_dat date,
	end_dat date,
	city varchar(50),
	country varchar(50),
	leg_adr varchar(150),
	leg_lat decimal(9,1),
	leg_long decimal(9,1),
	tot_distance decimal(9,1),
	veh varchar(100),
	veh_typ varchar(30)
)

	insert into #t_cnr(cus_nme, cus_lat, cus_long, wrh_lat, wrh_long, bgn_dat, end_dat, city, country, leg_adr, leg_lat, leg_long, veh, veh_typ)
	select distinct concat(c.fnm, ' ', c.snm),a.lat, a.long, w.wrh_lat, w.wrh_long, convert(date, s.sta_dat),convert(date,s.end_dat), a.city, a.country, 
			isnull(sl.leg_adr,0), isnull(sl.leg_lat,0), isnull(sl.leg_long,0), concat(vs.brd, ' ', vs.mdl), vt.dsc
	from trn.t_cus c
		inner join trn.t_adr a on a.cus_id = c.id
		inner join trn.t_ord o on o.cus_id = c.id
		inner join trn.t_ship s on o.ship_id = s.id
		inner join trn.t_wrh w on s.wrh_id = w.id
		inner join trn.t_veh v on s.veh_id = v.id
		inner join trn.t_veh_typ vt on vt.id = v.typ_id
		inner join trn.t_veh_spec vs on vs.id = v.spec_id
		left outer join trn.t_ship_leg sl on sl.ship_id = s.id

	update c1
	set distance_wo_legs = (select acos(sin(pi() *  wrh_lat/ 180.0) * sin(pi() * cus_lat / 180.0) + cos(pi() * wrh_lat / 180.0) * cos(pi() *
						cus_lat/180.0) * cos(pi() * cus_long/180.0 - pi() * wrh_long / 180.0)) * 6371
					from #t_cnr c2
					where c1.cus_nme = c2.cus_nme),
		distance_frm_sta_to_leg= (select acos(sin(pi() *  wrh_lat/ 180.0) * sin(pi() * c2.leg_lat / 180.0) + cos(pi() * wrh_lat / 180.0) * cos(pi() *
						c2.leg_lat/180.0) * cos(pi() * c2.leg_long/180.0 - pi() * wrh_long / 180.0)) * 6371
					from #t_cnr c2
					where c1.cus_nme = c2.cus_nme),
		distance_from_end_to_leg = (select acos(sin(pi() *  c2.cus_lat/ 180.0) * sin(pi() * c2.leg_lat / 180.0) + cos(pi() * c2.cus_lat / 180.0) * cos(pi() *
						c2.leg_lat/180.0) * cos(pi() * c2.leg_long/180.0 - pi() * c2.cus_long / 180.0)) * 6371
					from #t_cnr c2
					where c1.cus_nme = c2.cus_nme)
	from #t_cnr c1

	update c1
		set tot_distance = (select distance_wo_legs + distance_frm_sta_to_leg + distance_from_end_to_leg)
	from #t_cnr c1

	insert into #t_dta (cus_nme, city, country, veh, veh_typ)
	select cus_nme, city, country, veh, veh_typ
	from #t_cnr

	update d
		set dlv_spd_in_hours = (select tot_distance / @p_avg_spd
								from #t_cnr c
								where c.cus_nme = d.cus_nme)
	from #t_dta d

	select cus_nme, dlv_spd_in_hours, city, country, veh, veh_typ
	from #t_dta

	select sum(dlv_spd_in_hours) as DeliveriesSpeed, city as City, country as Country, veh_typ as VehicleType
	from #t_dta
	group by city, country, veh_typ

end try
begin catch
		
	declare @p_err_mes varchar(4000),
			@p_err_sev int,
			@p_err_sta int,
			@p_err_lne int,
			@p_err_num int,
			@p_prc_nme varchar(100)
			
	select @p_err_mes = error_message(),
			@p_err_sev = error_severity(),
			@p_err_sta = error_state(),
			@p_err_lne = error_line(),
			@p_err_num = error_number(),
			@p_prc_nme = isnull(object_schema_name(@@procid),'') + '.' + isnull(object_name(@@procid),'Custom Script')
	
	raiserror(@p_err_mes, @p_err_sev, 16)
	
end catch
set nocount off


GO

