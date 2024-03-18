create database Ex01

go

use Ex01

go

create table produto (
	codigo	int				not null,
	nome	varchar(100)	not null,
	valor	decimal(7,2)	not null
	primary key (codigo)
)

go

create table entrada (
	codigoTransacao		int		not null,
	codigoProduto		int		not null,
	quantidade			int		not null,
	valorTotal			decimal(7,2)	not null
	primary key (codigoTransacao)
	foreign key(codigoProduto) references produto(codigo)
)

create table saida (
	codigoTransacao		int		not null,
	codigoProduto		int		not null,
	quantidade			int		not null,
	valorTotal			decimal(7,2)	not null
	primary key (codigoTransacao)
	foreign key(codigoProduto) references produto(codigo)
)

go

--drop procedure sp_insereTransacao 

create procedure sp_insereTransacao (@op char(1), @codigoProd int, @codigoTransacao int, @qtd int, @saida varchar(100) output)
as 
	declare @valorTotal decimal(7,2), @tabela varchar(10), @query varchar(200), @erro varchar(100), @valorunit decimal(7,2)
	set @valorTotal = 0

	set @codigoProd = (select codigo from produto where codigo = @codigoProd)

	if(@qtd > 0 and @codigoProd is not null)begin

	if(@op = 'e')begin
		set @tabela = 'entrada'
	end else begin
		set @tabela = 'saida' 
	end

	begin try

		set @valorunit = (select valor from produto where codigo = @codigoProd)
		set @valorTotal = @valorunit * @qtd

		set @query = 'insert into ' + @tabela + ' values ('+ cast(@codigoTransacao as varchar(10)) + ', ' + cast(@codigoProd as varchar(10)) + ', ' 
				 + cast(@qtd as varchar(10)) + ', ' + cast(@valorTotal as varchar(10)) + ')'

		print @query
		Exec (@query)
		set @saida = @tabela + ' inserida com sucesso'

	end try
	begin catch
		set @erro = ERROR_MESSAGE()
		if (@erro like '%primary%') begin
			set @erro = 'produto duplicado'
		end else begin
			set @erro = 'erro na inserção de valores na tabela ' + @tabela
		end
			raiserror(@erro, 16, 1)
	end catch
	end else begin
		if(@qtd <= 0)begin
			set @erro = 'quantidade de produto deve ser maior que 0'
		end else begin
			set @erro = 'Produto inexisrente'
		end
			raiserror(@erro, 16, 1)
	end

-- testes 

INSERT INTO produto (codigo, nome, valor)
VALUES
    (1, 'Camiseta', 29.99),
    (2, 'Calça Jeans', 49.90),
    (3, 'Tênis', 79.99),
    (4, 'Moletom', 39.99);

declare @out varchar(80)
exec sp_insereTransacao e, 6, 5, 0,@out output
print @out

declare @out1 varchar(80)
exec sp_insereTransacao s, 2, 1, 20,@out1 output
print @out1

declare @out3 varchar(80)
exec sp_insereTransacao e, 4, 5, 0,@out3 output
print @out3

select * from saida 
select * from entrada