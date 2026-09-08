SELECT 'd_produtos' AS tabela, COUNT(*) AS total_linhas FROM d_produtos
UNION ALL
SELECT 'd_clientes', COUNT(*) FROM d_clientes
UNION ALL
SELECT 'd_vendedores', COUNT(*) FROM d_vendedores
UNION ALL
SELECT 'f_pedidos_itens', COUNT(*) FROM f_pedidos_itens;
