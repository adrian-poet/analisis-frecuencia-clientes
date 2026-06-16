WITH Dias AS(
Select 
	v.Id_Cliente,
	c.Nombre,
	v.Cantidad,
	p.Precio_Venta,
	v.Fecha,
	LAG(v.Fecha) OVER (PARTITION BY v.Id_Cliente ORDER BY Fecha) AS Compra_Anterior,
	DATEDIFF(DAY, LAG(v.Fecha) OVER (PARTITION BY v.Id_Cliente ORDER BY Fecha), Fecha) AS Diferencia_Dias
FROM Fact_Ventas v
LEFT JOIN Dim_Clientes c ON c.Id_Cliente = v.Id_Cliente
LEFT JOIN Dim_Productos p ON p.Id_Producto = v.Id_Producto),
Calculos AS(
Select 
	Id_Cliente,
	Nombre,
	ROUND(AVG(CAST(Diferencia_Dias AS FLOAT)),2) AS Promedio_Frecuencia_Compra,
	MAX(Fecha) AS Ultima_Compra,
	DATEDIFF(DAY,MAX(Fecha), GETDATE() ) AS Dias_Ultima_Compra,
	SUM(Cantidad * Precio_Venta) AS Total_Comprado,
	ROUND(AVG (Cantidad * CAST(Precio_Venta AS FLOAT)),2) AS Tiket_promedio,
	COUNT(*) AS Cantidad_Compras
FROM Dias
GROUP BY Id_Cliente, Nombre
),
case_desviacion AS(
Select 
	*,
	CASE
	WHEN Dias_Ultima_Compra > (Promedio_Frecuencia_Compra * 2) Then 'Critico'
	WHEN Dias_Ultima_Compra > Promedio_Frecuencia_Compra then 'Atrasado'
	ELSE 'Activo'
	END AS Estado_Cliente,
	Dias_Ultima_Compra - Promedio_Frecuencia_Compra AS Desviacion_del_Promedio,
	Sum(Total_Comprado) OVER () AS Total_Global_Venta
From Calculos
),
porcentaje AS(
Select
	*,
ROUND((Total_Comprado/NULLIF(Sum(CAST(Total_Comprado AS FLOAT)) OVER (),0)) * 100.0,2) AS Porcentaje_Individual
From case_desviacion
),
porcentaje_acumulado AS(
Select
	*,
	ROUND(SUM(Total_Comprado) OVER (ORDER BY Total_Comprado DESC) / NULLIF(SUM(CAST(Total_Comprado AS FLOAT)) OVER (), 0) * 100.0, 2) AS Porcentaje_Acumulado
From porcentaje
),
case_pareto AS(
Select
	*,
	CASE 
    WHEN Porcentaje_Acumulado <= 80 THEN 'A'
    WHEN Porcentaje_Acumulado <= 95 THEN 'B'
    ELSE 'C'
END AS Segmento_ABC
from porcentaje_acumulado
)
Select * From case_pareto
