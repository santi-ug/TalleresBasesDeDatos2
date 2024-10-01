/*
 * 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package taller11.bdd2;

import java.math.BigDecimal;
import java.sql.*;

/**
 *
 * @author santi
 */
public class Taller11BDD2 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            Class.forName("oracle.jdbc.driver.OracleDriver");
            
            // Ejemplo Procedimiento
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "7975");
            
            CallableStatement exec = conn.prepareCall("call ejercicioclase.transferir_dinero(?,?,?)");
//            exec.setInt(1, 139493458);
//            exec.setInt(2, 993489327);
//            exec.setBigDecimal(3, new BigDecimal(2000));
//            exec.execute();
//            
//            // Ejemplo Funcion
//            exec = conn.prepareCall("call taller1.calc_area_circulo(?)");
//            exec.setBigDecimal(1, new BigDecimal(10));
//            ResultSet ans = exec.executeQuery();
//            BigDecimal radius = new BigDecimal(0);
//            while (ans.next()) {
//                radius = ans.getBigDecimal(1);
//            }
//            System.out.println(radius.doubleValue());
//            
//            // Ejemplo Return Query
//            exec = conn.prepareCall(" { call taller1.obtener_cuentas_saldos() } ");
//            ResultSet rqans = exec.executeQuery();
//            while (rqans.next()) {
//                System.out.println("CUENTA: " + rqans.getString("v_cuenta"));
//                System.out.println("SALDO: " + rqans.getBigDecimal("v_saldo"));
//            }
            
            // TALLER 11 --------------------------------------------------------
            
            // obtener_nomina_empleado taller 9
            System.out.println("TALLER 11 - PARTE A");
            exec = conn.prepareCall("{call taller9.obtener_nomina_empleado(?,?,?)}"); 
            exec.setString(1, "ID1");
            exec.setInt(2, 1);
            exec.setInt(3, 2023);
            ResultSet resultado = exec.executeQuery();
            while(resultado.next()){
                System.out.println("Nombre: " + resultado.getString("nombre"));
                System.out.println("Total Devengado: " + resultado.getFloat("total_devengado"));
                System.out.println("Total Deducciones: " + resultado.getFloat("total_deducciones"));
                System.out.println("Total: " + resultado.getFloat("total"));
            }          
            exec.execute();

            
            // total_por_contrato taller 9
            exec = conn.prepareCall("{call taller9.total_por_contrato(?)}"); 
            exec.setInt(1, 1); 
            ResultSet resultado2 = exec.executeQuery();
            while(resultado2.next()){
                System.out.println("Nombre: " + resultado2.getString("nombre"));
                System.out.println("Fecha Pago: " + resultado2.getDate("fecha_pago"));
                System.out.println("Ano: " + resultado2.getInt("ano"));
                System.out.println("Mes: " + resultado2.getInt("mes"));
                System.out.println("Total Devengado: " + resultado2.getFloat("total_devengado"));
                System.out.println("Total Deducciones: " + resultado2.getFloat("total_deducciones"));
                System.out.println("Total Nomina: " + resultado2.getFloat("total"));
            }          
            exec.execute();
            
            
            
            // Taller 11 - Oracle Taller 5
            System.out.println("\nTALLER 11 - PARTE B (Taller 5 en Oracle)");
            Connection orConn = DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:xe", "system", "7975");
            exec = orConn.prepareCall("CALL TALLER11.generar_auditoria(?, ?)");
            exec.setDate(1, java.sql.Date.valueOf("2020-10-28"));
            exec.setDate(2, java.sql.Date.valueOf("2022-02-20"));
            exec.execute();
            
            exec = conn.prepareCall("CALL TALLER11.simular_ventas_mes()");
            exec.execute();
            
            
            
            
            
            // Taller 11 - Oracle Taller 9
            System.out.println("\nTALLER 11 - PARTE B (Taller 9 en Oracle)");
            exec = orConn.prepareCall("{call TALLER11B.obtener_nomina_empleado(?,?,?)}"); 
            exec.setString(1, "ID1");
            exec.setInt(2, 1);
            exec.setInt(3, 2023);
            ResultSet resultado11a = exec.executeQuery();
            while(resultado.next()){
                System.out.println("Nombre: " + resultado11a.getString("nombre"));
                System.out.println("Total Devengado: " + resultado11a.getFloat("total_devengado"));
                System.out.println("Total Deducciones: " + resultado11a.getFloat("total_deducciones"));
                System.out.println("Total: " + resultado11a.getFloat("total"));
            }          
            exec.execute();

            
            exec = orConn.prepareCall("{call TALLER11B.total_por_contrato(?)}"); 
            exec.setInt(1, 1); 
            ResultSet resultado11b = exec.executeQuery();
            while(resultado2.next()){
                System.out.println("Nombre: " + resultado11b.getString("nombre"));
                System.out.println("Fecha Pago: " + resultado11b.getDate("fecha_pago"));
                System.out.println("Ano: " + resultado11b.getInt("ano"));
                System.out.println("Mes: " + resultado11b.getInt("mes"));
                System.out.println("Total Devengado: " + resultado11b.getFloat("total_devengado"));
                System.out.println("Total Deducciones: " + resultado11b.getFloat("total_deducciones"));
                System.out.println("Total Nomina: " + resultado11b.getFloat("total"));
            }          
            exec.execute();

            
            
            exec.close();
            conn.close();
            orConn.close();
            
            
            
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
    
}
