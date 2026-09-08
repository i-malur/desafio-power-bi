USE olist_db;

-- 1. Desativar modo estrito para evitar o erro de datas zeradas
SET sql_mode = '';

-- 2. Dimensão Produtos
DROP TABLE IF EXISTS d_produtos;
CREATE TABLE d_produtos AS
SELECT 
    p.product_id AS id_produto,
    p.product_category_name AS categoria_produto_pt,
    COALESCE(t.product_category_name_english, 'nao_informado') AS categoria_produto_en,
    p.product_name_lenght AS tamanho_nome_produto,
    p.product_description_lenght AS tamanho_descricao_produto,
    p.product_photos_qty AS quantidade_fotos_produto,
    p.product_weight_g AS peso_gramas,
    p.product_length_cm AS comprimento_cm,
    p.product_height_cm AS altura_cm,
    p.product_width_cm AS largura_cm
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;

-- 3. Dimensão Clientes
DROP TABLE IF EXISTS d_clientes;
CREATE TABLE d_clientes AS
SELECT 
    customer_id AS id_cliente_pedido,
    customer_unique_id AS id_unico_cliente,
    customer_zip_code_prefix AS cep_prefixo_cliente,
    customer_city AS cidade_cliente,
    customer_state AS estado_cliente
FROM olist_customers_dataset;

-- 4. Dimensão Vendedores
DROP TABLE IF EXISTS d_vendedores;
CREATE TABLE d_vendedores AS
SELECT 
    seller_id AS id_vendedor,
    seller_zip_code_prefix AS cep_prefixo_vendedor,
    seller_city AS cidade_vendedor,
    seller_state AS estado_vendedor
FROM olist_sellers_dataset;

-- 5. Deduplicação de Avaliações
DROP TABLE IF EXISTS stg_avaliacoes_dedup;
CREATE TABLE stg_avaliacoes_dedup AS
SELECT 
    order_id AS id_pedido,
    MAX(review_score) AS nota_avaliacao
FROM olist_order_reviews_dataset
GROUP BY order_id;

-- 6. Tabela Fato Pedidos Itens (Tratando datas 0000-00-00)
DROP TABLE IF EXISTS f_pedidos_itens;
CREATE TABLE f_pedidos_itens AS
SELECT 
    i.order_id AS id_pedido,
    i.order_item_id AS numero_item,
    o.customer_id AS id_cliente_pedido,
    i.seller_id AS id_vendedor,
    i.product_id AS id_produto,
    o.order_status AS status_pedido,
    
    -- Tratamento para datas zeradas
    NULLIF(o.order_purchase_timestamp, '0000-00-00 00:00:00') AS data_compra,
    NULLIF(o.order_approved_at, '0000-00-00 00:00:00') AS data_aprovacao_pagamento,
    NULLIF(o.order_delivered_carrier_date, '0000-00-00 00:00:00') AS data_envio_transportadora,
    NULLIF(o.order_delivered_customer_date, '0000-00-00 00:00:00') AS data_entrega_cliente,
    NULLIF(o.order_estimated_delivery_date, '0000-00-00 00:00:00') AS data_estimada_entrega,
    
    i.price AS preco_produto,
    i.freight_value AS valor_frete,
    (i.price + i.freight_value) AS valor_total_item,
    
    -- Cálculos de Prazos Operacionais em Dias (MySQL)
    DATEDIFF(NULLIF(o.order_delivered_customer_date, '0000-00-00 00:00:00'), NULLIF(o.order_purchase_timestamp, '0000-00-00 00:00:00')) AS dias_entrega_real,
    DATEDIFF(NULLIF(o.order_estimated_delivery_date, '0000-00-00 00:00:00'), NULLIF(o.order_purchase_timestamp, '0000-00-00 00:00:00')) AS dias_estimados_prometidos,
    DATEDIFF(NULLIF(o.order_delivered_customer_date, '0000-00-00 00:00:00'), NULLIF(o.order_estimated_delivery_date, '0000-00-00 00:00:00')) AS dias_atraso,
    
    CASE 
        WHEN NULLIF(o.order_delivered_customer_date, '0000-00-00 00:00:00') > NULLIF(o.order_estimated_delivery_date, '0000-00-00 00:00:00') THEN 1 
        ELSE 0 
    END AS flag_pedido_atrasado,
    
    rev.nota_avaliacao
FROM olist_order_items_dataset i
INNER JOIN olist_orders_dataset o ON i.order_id = o.order_id
LEFT JOIN stg_avaliacoes_dedup rev ON o.order_id = rev.id_pedido
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
  AND o.order_delivered_customer_date != '0000-00-00 00:00:00';
