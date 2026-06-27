-- ==========================================================================================
-- PROYECTO: SEGMENTACIÓN DE CLIENTES, ANÁLISIS DE CHURN Y CLASIFICACIÓN ABC (PARETO)
-- OBJETIVO: Analizar el comportamiento de compra, detectar desvíos en la frecuencia activa 
--           y segmentar la cartera de clientes según su impacto en la facturación total.
-- ==========================================================================================

WITH Dias AS (
    -- Paso 1: Cálculo de la diferencia de días entre compras consecutivas por cliente
    SELECT 
        v.Id_Cliente,
        c.Nombre,
        v.Cantidad,
        p.Precio_Venta,
        v.Fecha,
        LAG(v.Fecha) OVER (
            PARTITION BY v.Id_Cliente 
            ORDER BY v.Fecha
        ) AS Compra_Anterior,
        DATEDIFF(
            DAY, 
            LAG(v.Fecha) OVER (PARTITION BY v.Id_Cliente ORDER BY v.Fecha), 
            v.Fecha
        ) AS Diferencia_Dias
    FROM Fact_Ventas v
    LEFT JOIN Dim_Clientes c ON c.Id_Cliente = v.Id_Cliente
    LEFT JOIN Dim_Productos p ON p.Id_Producto = v.Id_Producto
),

Calculos AS (
    -- Paso 2: Consolidación de métricas clave e históricos de compra por cliente
    SELECT 
        Id_Cliente,
        Nombre,
        ROUND(AVG(CAST(Diferencia_Dias AS FLOAT)), 2) AS Promedio_Frecuencia_Compra,
        MAX(Fecha) AS Ultima_Compra,
        DATEDIFF(DAY, MAX(Fecha), GETDATE()) AS Dias_Ultima_Compra,
        SUM(Cantidad * Precio_Venta) AS Total_Comprado,
        ROUND(AVG(Cantidad * CAST(Precio_Venta AS FLOAT)), 2) AS Tiket_promedio,
        COUNT(*) AS Cantidad_Compras
    FROM Dias
    GROUP BY Id_Cliente, Nombre
),

case_desviacion AS (
    -- Paso 3: Identificación de riesgo de Churn según desvío de su frecuencia habitual
    SELECT 
        *,
        CASE
            WHEN Dias_Ultima_Compra > (Promedio_Frecuencia_Compra * 2) THEN 'Critico'
            WHEN Dias_Ultima_Compra > Promedio_Frecuencia_Compra THEN 'Atrasado'
            ELSE 'Activo'
        END AS Estado_Cliente,
        Dias_Ultima_Compra - Promedio_Frecuencia_Compra AS Desviacion_del_Promedio,
        SUM(Total_Comprado) OVER () AS Total_Global_Venta
    FROM Calculos
),

porcentaje AS (
    -- Paso 4: Cálculo del peso porcentual de cada cliente sobre el total de ventas
    -- Se utiliza NULLIF para prevenir errores de división por cero de manera segura
    SELECT
        *,
        ROUND((Total_Comprado / NULLIF(SUM(CAST(Total_Comprado AS FLOAT)) OVER (), 0)) * 100.0, 2) AS Porcentaje_Individual
    FROM case_desviacion
),

porcentaje_acumulado AS (
    -- Paso 5: Cálculo del porcentaje acumulado ordenado de mayor a menor ingreso
    SELECT
        *,
        ROUND(SUM(Total_Comprado) OVER (ORDER BY Total_Comprado DESC) / NULLIF(SUM(CAST(Total_Comprado AS FLOAT)) OVER (), 0) * 100.0, 2) AS Porcentaje_Acumulado
    FROM porcentaje
),

case_pareto AS (
    -- Paso 6: Clasificación final utilizando la regla de Pareto (80/20) para determinar relevancia
    SELECT
        *,
        CASE 
            WHEN Porcentaje_Acumulado <= 80 THEN 'A' -- Clientes VIP (Generan el 80% de los ingresos)
            WHEN Porcentaje_Acumulado <= 95 THEN 'B' -- Clientes de valor medio
            ELSE 'C'                                 -- Clientes de menor impacto en facturación
        END AS Segmento_ABC
    FROM porcentaje_acumulado
)

-- ==========================================================================================
-- RESULTADO FINAL
-- ==========================================================================================
SELECT * 
FROM case_pareto;
Select * From case_pareto
