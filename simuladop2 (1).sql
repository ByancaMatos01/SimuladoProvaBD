CREATE DATABASE simu1
GO
USE simu1
GO
CREATE TABLE editora (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
site			VARCHAR(40)		NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE autor (
codigo			INT				NOT NULL,
nome			VARCHAR(30)		NOT NULL,
biografia		VARCHAR(100)	NOT NULL
PRIMARY KEY (codigo)
)
GO
CREATE TABLE estoque (
codigo			INT				NOT NULL,
nome			VARCHAR(100)	NOT NULL	UNIQUE,
quantidade		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL	CHECK(valor > 0.00),
codEditora		INT				NOT NULL,
codAutor		INT				NOT NULL
PRIMARY KEY (codigo)
FOREIGN KEY (codEditora) REFERENCES editora (codigo),
FOREIGN KEY (codAutor) REFERENCES autor (codigo)
)
GO
CREATE TABLE compra (
codigo			INT				NOT NULL,
codEstoque		INT				NOT NULL,
qtdComprada		INT				NOT NULL,
valor			DECIMAL(7,2)	NOT NULL,
dataCompra		DATE			NOT NULL
PRIMARY KEY (codigo, codEstoque, dataCompra)
FOREIGN KEY (codEstoque) REFERENCES estoque (codigo)
)
GO
INSERT INTO editora VALUES
(1,'Pearson','www.pearson.com.br'),
(2,'Civilização Brasileira',NULL),
(3,'Makron Books','www.mbooks.com.br'),
(4,'LTC','www.ltceditora.com.br'),
(5,'Atual','www.atualeditora.com.br'),
(6,'Moderna','www.moderna.com.br')
GO
INSERT INTO autor VALUES
(101,'Andrew Tannenbaun','Desenvolvedor do Minix'),
(102,'Fernando Henrique Cardoso','Ex-Presidente do Brasil'),
(103,'Diva Marília Flemming','Professora adjunta da UFSC'),
(104,'David Halliday','Ph.D. da University of Pittsburgh'),
(105,'Alfredo Steinbruch','Professor de Matemática da UFRS e da PUCRS'),
(106,'Willian Roberto Cereja','Doutorado em Lingüística Aplicada e Estudos da Linguagem'),
(107,'William Stallings','Doutorado em Ciências da Computacão pelo MIT'),
(108,'Carlos Morimoto','Criador do Kurumin Linux')
GO
INSERT INTO estoque VALUES
(10001,'Sistemas Operacionais Modernos ',4,108.00,1,101),
(10002,'A Arte da Política',2,55.00,2,102),
(10003,'Calculo A',12,79.00,3,103),
(10004,'Fundamentos de Física I',26,68.00,4,104),
(10005,'Geometria Analítica',1,95.00,3,105),
(10006,'Gramática Reflexiva',10,49.00,5,106),
(10007,'Fundamentos de Física III',1,78.00,4,104),
(10008,'Calculo B',3,95.00,3,103)
GO
INSERT INTO compra VALUES
(15051,10003,2,158.00,'04/07/2021'),
(15051,10008,1,95.00,'04/07/2021'),
(15051,10004,1,68.00,'04/07/2021'),
(15051,10007,1,78.00,'04/07/2021'),
(15052,10006,1,49.00,'05/07/2021'),
(15052,10002,3,165.00,'05/07/2021'),
(15053,10001,1,108.00,'05/07/2021'),
(15054,10003,1,79.00,'06/08/2021'),
(15054,10008,1,95.00,'06/08/2021')


select*from autor
select*from compra
select*from estoque
select*from editora

--1) Consultar nome, valor unitário, nome da editora e nome do autor dos livros do estoque que foram vendidos. Não podem haver repetições.	
select DISTINCT  est.nome as'nome do livro', est.valor as 'valor', ed.nome as 'Nome da editora', aut.nome as'Nome autor'
from estoque est inner join autor aut on est.codAutor= aut.codigo
inner join editora ed on est.codEditora= ed.codigo
--2) Consultar nome do livro, quantidade comprada e valor de compra da compra 15051	
select est.nome as 'Nome do livro', comp.qtdComprada as 'Quantidade comprada', comp.valor as 'Valor da compra' 
from estoque est inner join compra comp  on comp.codEstoque= est.codigo
where comp.codigo=15051
--3) Consultar Nome do livro e site da editora dos livros da Makron books (Caso o site tenha mais de 10 dígitos, remover o www.).
select est.nome as 'nome do livro',
  Case 
       When Len(ed.site)>10 then Replace (ed.site, 'www.', '') 
	   else ed.site
	   end as sites
from estoque est inner join editora ed on est.codEditora= ed.codigo
where ed.nome like '%Makron%'

--4) Consultar nome do livro e Breve Biografia do David Halliday
select est.nome as 'Nome do livro', aut.biografia
from estoque est inner Join autor aut on est.codAutor=aut.codigo
where aut.nome like '%David%'

--5) Consultar código de compra e quantidade comprada do livro Sistemas Operacionais Modernos
select est.codigo as 'Codigo do livro', est.nome as 'nome do livro', comp.qtdComprada as 'Quantidade comprada'
from estoque est inner join compra comp on comp.codEstoque= est.codigo
where est.nome like '%Sistemas%'
--6) Consultar quais livros não foram vendidos  
select est.codigo as 'codigo do livro', est.nome as 'Nome do Livro'
from estoque est left join compra comp on comp.codEstoque=est.codigo
where comp.qtdComprada is null
--7) Consultar quais livros foram vendidos e não estão cadastrados	
select est.codigo as 'codigo do livro', est.nome as 'Nome do livro'
from estoque est left join compra c on est.codigo=c.codEstoque
where c.codigo is null
--8) Consultar Nome e site da editora que não tem Livros no estoque (Caso o site tenha mais de 10 dígitos, remover o www.)
select ed.nome as 'Nome da editora',
  Case 
  When len(ed.site) <10 Then Replace (ed.site,'www.',' ')
  else ed.site
  end as 'site editora'
from editora ed 
where not exists (select 1
                   from estoque est 
				   where ed.codigo= est.codEditora
				  )

--9) Consultar Nome e biografia do autor que não tem Livros no estoque (Caso a biografia inicie com Doutorado, substituir por Ph.D.)
select aut.nome as 'Nome do Autor',
case 
When aut.biografia like 'Doutorado%' then Replace (aut.biografia, 'Doutorado', 'PH.D.')
else aut.biografia
end as 'Biografia'
from autor aut left join estoque est on 
aut.codigo= est.codAutor
where est.codigo is null

--10) Consultar o nome do Autor, e o maior valor de Livro no estoque. Ordenar por valor descendente	
select aut.nome as 'Nome do autor', Max(est.valor) as 'Valor do estoque' 
from autor aut inner join estoque est on aut.codigo= est.codAutor
GROUP BY aut.nome
order by Max (est.valor) desc

--11) Consultar o código da compra, o total de livros comprados e a soma dos valores gastos. Ordenar por Código da Compra ascendente.
select comp.codigo as 'Codigo da Compra', SUM(comp.qtdComprada) as 'Total de livros comprados', SUM(comp.valor) as 'Soma dos valores gastos'
from compra comp
GROUP BY comp.codigo
Order by comp.codigo 

--12) Consultar o nome da editora e a média de preços dos livros em estoque.Ordenar pela Média de Valores ascendente.
select ed.nome as 'Nome da editora', AVG(est.valor) as'Valor da compra'
from editora ed inner join estoque est on est.codEditora= ed.codigo
GROUP BY ed.nome
Order by AVG(est.valor)

--13) Consultar o nome do Livro, a quantidade em estoque o nome da editora, o site da editora (Caso o site tenha mais de 10 dígitos, remover o www.), criar uma coluna status onde:	
	--Caso tenha menos de 5 livros em estoque, escrever Produto em Ponto de Pedido
	--Caso tenha entre 5 e 10 livros em estoque, escrever Produto Acabando
	--Caso tenha mais de 10 livros em estoque, escrever Estoque Suficiente
	--A Ordenação deve ser por Quantidade ascendente
select est.nome as 'Nome', est.quantidade as 'quantidade', ed.nome as 'nome da editora', 
CASE
WHEN Len(ed.site)>10 then REPLACE (ed.site,'www.',' ') 
else ed.site
end as 'Site',

Case 
When (est.quantidade) <5 then 'Produto em ponto de pedido'
When (est.quantidade)<=5 and (est.quantidade)>=10 then 'Produto acabado'
else 'Estoque insuficiente'
end as 'status'
from estoque est inner join editora ed on est.codEditora= ed.codigo
ORDER BY 
    est.quantidade ASC;

--14) Para montar um relatório, é necessário montar uma consulta com a seguinte saída: Código do Livro, Nome do Livro, Nome do Autor, Info Editora (Nome da Editora + Site) de todos os livros	
	--Só pode concatenar sites que não são nulos
SELECT es.codigo, es.nome, a.nome,
	CASE WHEN e.site IS NOT NULL
	THEN 
		e.nome + ' - ' + e.site
	ELSE
		e.nome
	END AS info_site
FROM estoque es, autor a, editora e
WHERE es.codAutor = a.codigo AND es.codEditora = e.codigo

--15) Consultar Codigo da compra, quantos dias da compra até hoje e quantos meses da compra até hoje	
select DISTINCT comp.codigo  as 'Codigo de compra', comp.dataCompra as 'Data da compra',
DateDiff(Day, comp.dataCompra, GETDATE()) as 'dias até hoje',
DateDiff(MONTH, comp.dataCompra, GETDATE()) as 'Meses até hoje',
DATEDIFF(year, comp.dataCompra,GETDATE()) as 'ano até aqui'

from compra comp

--16) Consultar o código da compra e a soma dos valores gastos das compras que somam mais de 200.00	
select comp.codigo as 'Codigo da compra', SUM(comp.valor) as 'soma dos valores'
from compra comp
group by comp.codigo
Having Sum(comp.valor)<200


