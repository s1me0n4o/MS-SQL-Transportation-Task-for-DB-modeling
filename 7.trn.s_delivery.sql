create or alter proc trn.s_delivery
	@p_wrh_id int,
	@p_ord_id int,
	@p_cln_id int,
	@p_sta_dat smalldatetime,
	@p_end_dat smalldatetime,
	@p_leg_adr varchar(150) = null,
	@p_leg_lat decimal(9,1) = null,
	@p_leg_long decimal(9,1) = null,
	@p_veh_id int,
	@p_drv_fnm varchar(50),
	@p_drv_snm varchar(50),
	@p_out bit = 0
as
--declare
	--@p_wrh_id int = 1,
	--@p_ord_id int = 3,
	--@p_cln_id int = 2,
	--@p_sta_dat smalldatetime = '2018-12-17',
	--@p_end_dat smalldatetime = '2018-12-24',
	--@p_leg_adr varchar(150) = null,
	--@p_leg_lat decimal(9,1) = null,
	--@p_leg_long decimal(9,1) = null,
	--@p_veh_id int = 1,
	--@p_drv_fnm varchar(50) = 'Ivan',
	--@p_drv_snm varchar(50) = 'Ivanov',
	--@p_out bit = 1


begin try
set nocount on
	
	declare @p_cur_dat smalldatetime = getdate(),
			@p_admin varchar(20) = 'Administrator',
			@p_sta_pnt varchar(150),
			@p_end_pnt varchar(150),
			@p_ship_leg_id int,
			@p_ship_id int,
			@p_drv_id int = null
			
	select top 1 @p_sta_pnt = wrh_adr
	from trn.t_wrh
	where id = @p_wrh_id
	
	select top 1 @p_end_pnt = concat(a.adr, ' ', a.city)
	from trn.t_cus c
		inner join trn.t_adr a on a.cus_id = c.id
	where c.id = @p_cln_id

	if exists (select * from trn.t_emp where fnm = @p_drv_fnm and snm = @p_drv_snm)
	begin
		select top 1 @p_drv_id = id
		from trn.t_emp
	end

	if @p_sta_pnt is not null and len(@p_sta_pnt) > 0 and @p_end_pnt is not null and len(@p_end_pnt) > 0 
	begin
		if not exists(select top 1 * from trn.t_ship where end_pnt = @p_end_pnt) 
		begin
			if exists(select top 1 * from trn.t_ord where cus_id = @p_cln_id and id = @p_ord_id)
			begin
				insert into trn.t_ship (wrh_id, veh_id, drv_id, drv_nme, bgn_pnt, end_pnt, sta_dat, end_dat, cre_dat, cre_by, upd_dat, upd_by)
				select @p_wrh_id, @p_veh_id, @p_drv_id, concat(@p_drv_fnm, ' ', @p_drv_snm), @p_sta_pnt, @p_end_pnt, @p_sta_dat, @p_end_dat, @p_cur_dat, @p_admin, @p_cur_dat, @p_admin
		
				set @p_ship_id = scope_identity()

				update trn.t_ord
				set ship_id = @p_ship_id
				where cus_id = @p_cln_id
			end
		end
		else
		begin
			select top 1 @p_ship_id = id 
			from trn.t_ship
			where bgn_pnt = @p_sta_pnt and end_pnt = @p_end_pnt
			
			update trn.t_ord
			set ship_id = @p_ship_id
			where cus_id = @p_cln_id and id = @p_ord_id
		end
	end
	
	if @p_leg_adr is not null and len(@p_leg_adr) > 0 and @p_leg_lat is not null and @p_leg_long is not null 	
	begin
		insert into trn.t_ship_leg (ship_id, leg_adr, leg_lat, leg_long, cre_dat, cre_by, upd_dat, upd_by)
		select @p_ship_id, @p_leg_adr, @p_leg_lat, @p_leg_long, @p_cur_dat, @p_admin, @p_cur_dat, @p_admin

		set @p_ship_leg_id = scope_identity()
	end

	if @p_out = 1
	begin
		select @p_ship_id as ship_id, @p_ship_leg_id as ship_leg_id
	end
	
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

