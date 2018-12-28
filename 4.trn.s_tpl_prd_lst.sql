
	
	create procedure trn.s_tpl_prd_lst
	as
	begin try
	set nocount on
		
		select p.id as prd_id, p.dsc as prd_dsc, w.wrh_adr as wrh_adr
		from trn.t_tpl_prd p
			inner join trn.t_wrh w on w.id = p.wrh_id
		order by p.ord asc

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
