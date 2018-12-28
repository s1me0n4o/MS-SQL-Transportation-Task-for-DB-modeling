create or alter proc trn.s_flu_con
	@p_tim_of_day bit = 1, -- 0 noramal traffic, 1 a lot of traffic,
	@p_weather bit = 0 -- 0 good weather conditions, bad weather conditions
as
begin try
set nocount on

begin try drop table #t_cnr end try begin catch end catch
begin try drop table #t_dta end try begin catch end catch

	declare @p_tim_of_day_pnt decimal(9,2),
			@p_weather_pnt decimal(9,2)

create table #t_dta
(
	cus_nme varchar(50),
	avg_flu_con decimal(9,2),
	brand varchar(50),
	model varchar(50),
	driver varchar(75),
	time_of_day varchar(50),
	weather_con varchar(50)
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
	veh_brd varchar(50),
	veh_mdl varchar(50),
	veh_typ varchar(30),
	flu_con_per_100_km decimal(9,2),
	flu_con_per_weather_percent decimal(9,1),
	flu_con_per_time_day_percent decimal(9,1),
	flu_con_per_dist decimal(9,1),
	drv_nme varchar(50)
)

	if @p_tim_of_day = 1
	begin
		set @p_tim_of_day_pnt = 0.2
	end
	else
	begin
		set @p_tim_of_day_pnt = 0
	end

	if @p_weather = 1
	begin
		set @p_weather_pnt = 0.1
	end
	else
	begin
		set @p_weather_pnt = 0
	end

	insert into #t_cnr(cus_nme, cus_lat, cus_long, wrh_lat, wrh_long, bgn_dat, end_dat, city, country, leg_adr, leg_lat, leg_long, veh_brd, veh_mdl, veh_typ,
					   flu_con_per_100_km, flu_con_per_weather_percent, flu_con_per_time_day_percent, drv_nme)
	select concat(c.fnm, ' ', c.snm),a.lat, a.long, w.wrh_lat, w.wrh_long, convert(date, s.sta_dat),convert(date,s.end_dat), a.city, a.country, 
			isnull(sl.leg_adr,0), isnull(sl.leg_lat,0), isnull(sl.leg_long,0), vs.brd, vs.mdl, vt.dsc, (vs.flu_con_per_100_km / 100), @p_weather_pnt,
			@p_tim_of_day_pnt, s.drv_nme
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
					where c1.cus_lat = c2.cus_lat),
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

	update c1
		set flu_con_per_dist = (select c1.flu_con_per_100_km * c1.tot_distance)
	from #t_cnr c1

	select * 
	from #t_cnr

	insert into #t_dta (cus_nme, brand, model, driver, time_of_day, weather_con)
	select cus_nme ,veh_brd, veh_mdl, drv_nme, iif(@p_tim_of_day = 0, 'Normal Traffic','A lot of traffic'), iif(@p_weather = 0,'Good Weather Conditions','Bad Weather Conditions')
	from #t_cnr

	update d
	set avg_flu_con = (select avg((c.flu_con_per_100_km + flu_con_per_weather_percent + flu_con_per_time_day_percent) * flu_con_per_dist)
					   from #t_cnr c
					   where d.cus_nme = c.cus_nme)
	from #t_dta d

	select avg(avg_flu_con),brand,driver, model,time_of_day, weather_con
	from #t_dta
	group by brand, model,time_of_day, weather_con, driver

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

