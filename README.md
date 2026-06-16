# Análisis de Recencia, Frecuencia y Segmentación de Clientes (ABC) en SQL

## 📈 Visión General del Proyecto
Este proyecto implementa un modelo de inteligencia de clientes avanzado enfocado en el **análisis del comportamiento de compra, la detección temprana de inactividad (Churn de cuentas) y la segmentación estratégica de valor**. 

A través de una arquitectura de código altamente modular, el script procesa transacciones históricas combinando la lógica de **Recencia y Frecuencia (RF)** con métricas financieras. El objetivo principal es clasificar dinámicamente la salud de la cartera de clientes y predecir alertas de desvío operativo para activar estrategias comerciales de retención dirigidas.

---

## 🛠️ Tecnologías y Conceptos Avanzados Aplicados
- **Lenguaje:** T-SQL / SQL Server.
- **Modelado Analítico de Tiempos:** Uso de funciones de ventana `LAG()` y `DATEDIFF()` secuenciales para medir la cadencia de compra individual (tiempo inter-compra).
- **Métricas Basadas en Tiempo Real:** Incorporación de `GETDATE()` para contrastar la inactividad real actual vs. los patrones históricos propios de cada cliente.
- **Lógica de Alertas Predictivas:** Creación de estados condicionales basados en el desvío estándar de la frecuencia promedio por cuenta.
- **Estructuras de Control Avanzadas:** Uso intensivo de **Common Table Expressions (CTEs) secuenciales** para garantizar un código modular, mantenible y de alta legibilidad.

---

## 📐 Estructura y Pipeline de Datos (Arquitectura Modular)

El pipeline de análisis se consolida a través de capas embebidas de procesamiento utilizando CTEs independientes:

### 1. Capa Transaccional (`Dias`)
Combina las dimensiones de productos y clientes con la tabla de hechos de ventas (`Fact_Ventas`). Utiliza funciones particionadas para determinar la fecha exacta de la orden anterior y aislar la brecha exacta de días transcurridos entre transacciones consecutivas.

### 2. Capa de Agregación (`Calculos`)
Agrupa las interacciones para consolidar los KPIs básicos de ciclo de vida del cliente: ticket promedio, volumen total comprado y cantidad de transacciones.

### 3. Capa de Alertas Temporales (`case_desviacion`)
Calcula los días transcurridos desde la última compra (`GETDATE()`) y evalúa el riesgo de abandono. Si el retraso supera su patrón habitual, el cliente pasa a estado *Atrasado*; si duplica su frecuencia promedio, se enciende la alerta de estado *Crítico*.

### 4. Capa de Distribución Financiera (`porcentaje`)
Determina el peso porcentual individual de la facturación de cada cliente respecto a la venta global de la compañía.

### 5. Capa de Concentración Acumulada (`porcentaje_acumulado`)
Aplica funciones analíticas ordenadas para estructurar la curva de acumulación de ingresos indispensable para el análisis predictivo.

### 6. Capa de Clasificación Comercial (`case_pareto`)
Aplica las reglas de negocio definitivas para la segmentación de la cartera, aislando de forma exacta al **Grupo A** (clientes críticos que representan el 80% del valor del negocio).
