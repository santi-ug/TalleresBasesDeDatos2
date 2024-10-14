/*
 * 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package taller15;

import java.sql.*;

/**
 *
 * @author santi
 */
public class Taller15 {

    /**
     * @param args the command line arguments
     */
public static void main(String[] args) {
        try {
            // Load PostgreSQL JDBC driver
            Class.forName("org.postgresql.Driver");
            
            // Establish the connection
            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "7975");
            
            // -------------------- Example 1: Call guardar_libro (Insert a new book) --------------------
            System.out.println("Inserting a new book:");
            CallableStatement guardarLibro = conn.prepareCall("{call taller15.guardar_libro(?, ?)}");
            guardarLibro.setString(1, "9781234567897"); // ISBN
            guardarLibro.setString(2, "<libro><titulo>New Book Title</titulo><autor>John Doe</autor></libro>"); // XML description
            guardarLibro.execute();
            System.out.println("Book inserted successfully.");
            
            // -------------------- Example 2: Call actualizar_libro (Update an existing book) --------------------
            System.out.println("\nUpdating a book:");
            CallableStatement actualizarLibro = conn.prepareCall("{call taller15.actualizar_libro(?, ?)}");
            actualizarLibro.setString(1, "9781234567897"); // ISBN
            actualizarLibro.setString(2, "<libro><titulo>Updated Book Title</titulo><autor>Jane Doe</autor></libro>"); // Updated XML description
            actualizarLibro.execute();
            System.out.println("Book updated successfully.");
            
            // -------------------- Example 3: Call obtener_autor_libro_por_titulo (Get author by title) --------------------
            System.out.println("\nRetrieving author by book title:");
            CallableStatement obtenerAutor = conn.prepareCall("{? = call taller15.obtener_autor_libro_por_titulo(?)}");
            obtenerAutor.registerOutParameter(1, Types.VARCHAR);
            obtenerAutor.setString(2, "Updated Book Title");
            obtenerAutor.execute();
            String author = obtenerAutor.getString(1);
            System.out.println("Author: " + author);
            
            // -------------------- Example 4: Call obtener_libro (Get book by ISBN or title) --------------------
            System.out.println("\nRetrieving book by ISBN:");
            CallableStatement obtenerLibro = conn.prepareCall("{? = call taller15.obtener_libro(?, NULL)}");
            obtenerLibro.registerOutParameter(1, Types.SQLXML);
            obtenerLibro.setString(2, "9781234567897"); // ISBN
            obtenerLibro.execute();
            SQLXML bookXML = obtenerLibro.getSQLXML(1);
            System.out.println("Book XML: " + bookXML.getString());
            
            // Close the connection and statements
            guardarLibro.close();
            actualizarLibro.close();
            obtenerAutor.close();
            obtenerLibro.close();
            conn.close();
            
        } catch (Exception e) {
            System.out.println("Error: " + e.getMessage());
        }
    }
    
}

