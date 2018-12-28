
create procedure trn.s_ord_ins
	@p_cus_id int,
	@p_ord_dsc varchar(50),
	@p_ship_id int,
	@p_jsn nvarchar(max), 
  	@p_out bit = 0
as
	
		--declare
		--@p_cus_id int = 1,
		--@p_ord_dsc varchar(50) ='Order1',
		--@p_jsn nvarchar(max) =
		--'[
		--	{"ProductID":2, "Descriptopn":"Product 1", "WhareHouseID": 1},
		--	{"ProductID":3, "Descriptopn":"Product 2", "WhareHouseID": 1},
		--	{"ProductID":4, "Descriptopn":"Product 3", "WhareHouseID": 1},
		--	{"ProductID":9, "Descriptopn":"Product 8", "WhareHouseID": 2}
		-- ]',
		-- @p_out bit = 1

		--declare
		--@p_cus_id int = 1,
		--@p_ord_dsc varchar(50) ='Order2',
		--@p_jsn nvarchar(max) =
		--'[
		--	{"ProductID":5, "Descriptopn":"Product 5", "WhareHouseID": 1},
		--	{"ProductID":7, "Descriptopn":"Product 7", "WhareHouseID": 1}
		-- ]',
		-- @p_out bit = 1

		--declare
		--@p_cus_id int = 2,
		--@p_ord_dsc varchar(50) ='Order1',
		--@p_jsn nvarchar(max) =
		--'[
		--	{"ProductID":10, "Descriptopn":"Product 4", "WhareHouseID": 2},
		--	{"ProductID":9, "Descriptopn":"Product 6", "WhareHouseID": 2}
		-- ]',
		-- @p_out bit = 1


begin try
set nocount on
begin try drop table #t_dta end try begin catch end catch

	declare @p_ord_id int,
			@p_cur_dat smalldatetime = getdate(),
			@p_admin varchar(20) = 'Administrator',
			@p_dsc varchar(50),
			@p_prd_id int,
			@p_wrh_id int
	
		if isjson(@p_jsn) = 0
			raiserror ('Input parameter @p_jsn is not formatted properly.', 1, 16)

		if exists(select * from trn.t_cus where id = @p_cus_id)
		begin
			if not exists (select * from trn.t_ord where dsc = @p_ord_dsc)
			begin
				insert into trn.t_ord(cus_id, dsc, cre_dat, cre_by, upd_dat, upd_by)
				select @p_cus_id, @p_ord_dsc, @p_cur_dat, @p_admin, @p_cur_dat, @p_admin

				set @p_ord_id = scope_identity()
			end
			else
			begin
				set @p_ord_id = (select id from trn.t_ord where dsc = @p_ord_dsc)
			end 
		end

	select prd_id, dsc, wrh_id
	into #t_dta
	from openjson(@p_jsn)
	with (
			prd_id int '$.ProductID',
			dsc varchar(50) '$.Descriptopn',
			wrh_id int '$.WhareHouseID'
		 )

	declare cur_jsn cursor local fast_forward 
	for 
		 select *
		 from #t_dta

	open cur_jsn  
	fetch next from cur_jsn into @p_prd_id, @p_dsc, @p_wrh_id
	while @@fetch_status = 0  
	begin  

		insert into trn.t_prd(prd_id, ord_id, wrh_id, dsc, cre_dat, cre_by, upd_dat, upd_by)
		select @p_prd_id, @p_ord_id, @p_wrh_id,@p_dsc, @p_cur_dat, @p_admin, @p_cur_dat, @p_admin

	fetch next from cur_jsn into  @p_prd_id, @p_dsc, @p_wrh_id
	end  
	close cur_jsn  
	deallocate cur_jsn

	if @p_out = 1
		select @p_ord_id

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
