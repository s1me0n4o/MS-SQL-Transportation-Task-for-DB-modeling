create procedure trn.s_emp_ins
	@p_fnm varchar(50),
	@p_snm varchar(50),
	@p_wrh_id int,
	@p_out bit = 0
as

	--declare 
	--	@p_fnm varchar(50) = 'Elena',
	--	@p_snm varchar(50) = 'Georgieva',
	--	@p_wrh_id int = 2,
	--	@p_out bit = 0

begin try
set nocount on

	declare @p_emp_id int,
			@p_cur_dat smalldatetime = getdate(),
			@p_admin varchar(20) = 'Administrator'

		if len(@p_snm) > 0 and len(@p_fnm) > 0
		begin
			if exists(select * 
					  from trn.t_wrh
					  where id = @p_wrh_id)
			begin
				insert into trn.t_emp(fnm, snm, wrh_id, cre_by, cre_dat, upd_by, upd_dat)
				select @p_fnm, @p_snm, @p_wrh_id, @p_admin, @p_cur_dat, @p_admin, @p_cur_dat
			
			set @p_emp_id = scope_identity()
			end
		end

		if @p_out = 1
		begin
			select @p_emp_id as emp_id 
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
