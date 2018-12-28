create or alter proc trn.s_prd_lst
	@p_cus_id int,
	@p_ord_id int
as
begin try
set nocount on

	--declare @p_cus_id int = 1,
	--		@p_ord_id int =	0
		
	declare @p_true bit = 1

	if @p_ord_id = 0
	begin
		select p.prd_id, p.ord_id, p.wrh_id, p.dsc,c.id, concat(c.fnm, ' ' ,c.snm) as cus_nme
		from trn.t_prd p
			inner join trn.t_ord o on o.id = p.ord_id
			inner join trn.t_cus c on c.id = o.cus_id
		where c.id = @p_cus_id and p.avl = @p_true
	end
	else
	begin
		select  p.prd_id, p.ord_id, p.wrh_id, p.dsc,c.id, concat(c.fnm, ' ' ,c.snm) as cus_nme
		from trn.t_prd p
			inner join trn.t_ord o on o.id = p.ord_id
			inner join trn.t_cus c on c.id = o.cus_id
		where c.id = @p_cus_id and p.avl = @p_true and p.ord_id = @p_ord_id
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
