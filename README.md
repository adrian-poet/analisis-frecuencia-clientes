# Análisis de Recencia, Frecuencia y Segmentación de Clientes (ABC) en SQL 📊💳

## 📈 Visión General del Proyecto
Este proyecto implementa un modelo analítico avanzado enfocado en el **análisis del comportamiento de compra, la detección temprana de inactividad (Churn de cuentas) y la segmentación estratégica de valor** para la cartera de clientes. 

A través de una arquitectura de código altamente modular basada en Common Table Expressions (CTEs), el script procesa transacciones históricas combinando la lógica de **Recencia y Frecuencia (RF)** con métricas financieras. El objetivo principal es clasificar dinámicamente la salud de la cuenta y predecir alertas de desvío operativo para activar estrategias comerciales de retención dirigidas.

---

## 📊 Reporte de Negocio e Insights (PDF)
El desarrollo del pipeline técnico está respaldado por un estudio analítico integral que traduce las alertas del script en una matriz de accionabilidad comercial orientada a maximizar la rentabilidad.

* 📄 **[Ver Reporte Completo: Analisis_Comportamiento_Cliente.pdf](./Analisis_Comportamiento_Cliente.pdf)**

### 💡 Hallazgos Estratégicos y Acciones Quirúrgicas:
* **Matriz de Accionabilidad Comercial:** Vinculación directa entre el nivel de riesgo de churn (calculado según el desvío del comportamiento histórico) y el valor del cliente (Segmentación ABC), optimizando el presupuesto de retención.
* **Predicción de Riesgo Proactiva:** Identificación de clientes en fase crítica basados en la desviación de su cadencia habitual de compra, permitiendo intervenciones personalizadas antes de que se formalice la baja.
* **Estacionalidad y Canales de Pago:** Análisis del comportamiento transaccional según los ciclos de consumo, ticket promedio y preferencias de pago para diseñar campaigns de fidelización a medida.

---

## 🛠️ Tecnologías y Conceptos Avanzados Aplicados
* **Lenguaje:** T-SQL (SQL Server) / Standard SQL.
* **Modelado Analítico de Tiempos:** Uso de la función de ventana `LAG()` particionada por cliente y combinada con `DATEDIFF()` para aislar de forma exacta la brecha de días transcurridos entre compras consecutivas.
* **Métricas Basadas en Tiempo Real:** Incorporación de `GETDATE()` para contrastar los días de inactividad real actual frente al patrón de frecuencia promedio histórico de cada cuenta.
* **Robustez Matemática:** Implementación de `NULLIF()` combinada con funciones de agregación sobre ventanas globales (`OVER ()`) para prevenir de forma proactiva errores críticos de división por cero en el cálculo de porcentajes de concentración de ingresos.
* **Estructuras de Control Avanzadas:** Cadena secuencial de 6 capas de Common Table Expressions (CTEs) para garantizar un procesamiento eficiente, escalable y modular.

---

## 📐 Estructura y Pipeline de Datos (Arquitectura de las CTEs)

El pipeline de análisis se consolida a través de capas secuenciales independientes:

1. **`Dias` (Capa Transaccional):** Cruza ventas con dimensiones de clientes y productos (`LEFT JOIN`). Calcula la fecha de la orden previa para determinar la cadencia inter-compra.
2. **`Calculos` (Capa de Agregación):** Agrupa métricas a nivel de cliente para consolidar KPIs clave de ciclo de vida (Ticket Promedio, Facturación Total y Frecuencia Promedio).
3. **`case_desviacion` (Capa de Alertas Temporales):** Clasifica la salud de la cuenta en `Activo`, `Atrasado` (si supera su promedio) o `Critico` (si duplica su frecuencia habitual de compra).
4. **`porcentaje` (Capa de Distribución Financiera):** Mide el peso relativo de los ingresos de cada cliente frente al flujo de caja global de la compañía.
5. **`porcentaje_acumulado` (Capa de Concentración Acumulada):** Calcula el porcentaje acumulado dinámico ordenando la cartera de mayor a menor facturación para estructurar la curva de Pareto.
6. **`case_pareto` (Capa de Clasificación Comercial):** Segmenta la cartera aplicando la regla del 80/20 (`Grupo A` para el top 80%, `Grupo B` para el 15% siguiente, y `Grupo C` para la cola de la facturación).

## 💻 Código Fuente
El desarrollo completo de la vista analítica con el script optimizado se encuentra documentado y listo para su ejecución en la sección de archivos del repositorio:

* 💾 **[Ver Script SQL Completo](./script_analisis_clientes.sql)** 
