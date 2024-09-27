/*
 * 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package bd2procedimiento;

import java.math.BigDecimal;
import java.sql.*;

/**
 *
 * @author santi
 */
public class BD2Procedimiento {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            
            // Ejemplo Procedimiento
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "7975");
            
            CallableStatement exec = conn.prepareCall("call ejercicioclase.transferir_dinero(?,?,?)");
            exec.setInt(1, 139493458);
            exec.setInt(2, 993489327);
            exec.setBigDecimal(3, new BigDecimal(2000));
            exec.execute();
            
            // Ejemplo Funcion
            exec = conn.prepareCall("call taller1.calc_area_circulo(?)");
            exec.setBigDecimal(1, new BigDecimal(10));
            ResultSet ans = exec.executeQuery();
            BigDecimal radius = new BigDecimal(0);
            while (ans.next()) {
                radius = ans.getBigDecimal(1);
            }
            System.out.println(radius.doubleValue());
            
            // TALLER 10 --------------------------------------------------------
            
            // Taller 10 parte 1 - procedimiento 1
            exec = conn.prepareCall("call taller5.generar_auditoria(?,?)");
            exec.setDate(1, new Date(2020, 10, 28));
            exec.setDate(2, new Date(2022, 02, 20));
            exec.execute();
            
            // Taller 10 parte 1 - procedimiento 2
            exec = conn.prepareCall("call taller5.simular_ventas_mes()");
            exec.execute();
            
            // Taller 10 parte 2 - funcion 1
            exec = conn.prepareCall("call taller6.transacciones_total_mes(?,?)");
            exec.setInt(1, 13);
            exec.setInt(1, 6);
            ResultSet answer = exec.executeQuery();
            BigDecimal transTotal = new BigDecimal(0);
            while (answer.next()) {
                transTotal = answer.getBigDecimal(1);
            }
            System.out.println(transTotal.doubleValue());

            // Taller 10 parte 2 - funcion 2
            // No existe funcion almacenada
            
            
            
            exec.close();
            conn.close();
            
            
            
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
    
}
