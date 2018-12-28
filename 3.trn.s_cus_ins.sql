

create procedure trn.s_cus_ins
	@p_fnm varchar(50),
	@p_snm varchar(50),
	@p_cln_cmp_typ bit, -- company(1) or client(0)
	@p_adr varchar(75),
	@p_city varchar(75),
	@p_city_lat decimal(9,1),
	@p_city_long decimal(9,1),
	@p_country varchar(75),
	@p_out bit = 0
as

--declare
--	@p_fnm varchar(50) = 'Ivan',
--	@p_snm varchar(50)= 'Ivanov',
--	@p_cln_cmp_typ bit = 0, -- company(1) or client(0)
--	@p_adr varchar(75)='ul. Bogomil 1',
--	@p_city varchar(75)='Plovdiv',
--  @p_city_lat decimal(9,1) = 42.2,
--  @p_city_long decimal(9,1) = 24.5,
--	@p_country varchar(75)='BG',
--	@p_out bit = 0

	--declare
	--@p_fnm varchar(50) = 'Kristin',
	--@p_snm varchar(50)= 'Dimitrova',
	--@p_cln_cmp_typ bit = 0, -- company(1) or client(0)
	--@p_adr varchar(75)='bul. Vladislav Varnenchik',
	--@p_city varchar(75)='Varna',
 --   @p_city_lat decimal(9,1) = 43.2,
 --   @p_city_long decimal(9,1) = 27.8,
	--@p_country varchar(75)='BG',
	--@p_out bit = 0

	--declare
	--@p_fnm varchar(50) = 'Dimitar',
	--@p_snm varchar(50)= 'Alabashev',
	--@p_cln_cmp_typ bit = 0, -- company(1) or client(0)
	--@p_adr varchar(75)='bul. Kolio Ficheto 5005',
	--@p_city varchar(75)='Veliko Turnovo',
 --   @p_city_lat decimal(9,1) = 43.0,
 --   @p_city_long decimal(9,1) = 25.6,
	--@p_country varchar(75)='BG',
	--@p_out bit = 0
begin try
set nocount on
	
declare @p_cus_id int,
		@p_adr_id int,
		@p_cur_dat smalldatetime = getdate(),
		@p_admin varchar(20) = 'Administrator'

	if len(@p_snm) > 0
	begin
		if not exists(select * 
						from trn.t_cus c
						inner join trn.t_adr a  on a.cus_id = c.id
						where fnm = @p_fnm and snm = @p_snm and a.adr = @p_adr)
		begin
			begin try
				begin tran
					insert into trn.t_cus(fnm, snm, cln_cmp_typ, cre_dat, cre_by, upd_dat, upd_by)
					values(@p_fnm, @p_snm, @p_cln_cmp_typ, @p_cur_dat, @p_admin, @p_cur_dat, @p_admin)		
		
					set @p_cus_id = scope_identity() 
		
					insert into trn.t_adr(cus_id, adr, city, lat, long, country, cre_dat, cre_by, upd_dat, upd_by)
					values(@p_cus_id, @p_adr, @p_city, @p_city_lat, @p_city_long, @p_country, @p_cur_dat, @p_admin, @p_cur_dat, @p_admin)

					set @p_adr_id = scope_identity()
				commit tran
			end try
			begin catch
				if @@trancount > 0
					rollback						
			end catch
		end
	end

if @p_out = 1
begin
	select @p_cus_id as cus_id, 
			@p_adr_id as adr_id
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
