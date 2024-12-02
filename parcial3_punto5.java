/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.mycompany.parcial3bd2;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.Session;
import org.neo4j.driver.Query;

import java.util.Scanner;

/**
 *
 * @author Santi
 */
public class Punto5 {
  private static final Driver driver = org.neo4j.driver.GraphDatabase.driver(
      "bolt://localhost:7687", // URL del servidor de Neo4j
      AuthTokens.basic("neo4j", "Santiago04") // Credenciales de Neo4j (ajusta el usuario y la contraseña)
  );

  public static void main(String[] args) {
    Scanner scanner = new Scanner(System.in);

    try {
      int choice;
      do {
        System.out.println("\n=== Red Social ===");
        System.out.println("1. Crear Persona");
        System.out.println("2. Crear Comentario entre Personas");
        System.out.println("0. Salir");
        System.out.print("Opción seleccionada: ");
        choice = scanner.nextInt();
        scanner.nextLine(); // Consume el salto de línea

        switch (choice) {
          case 1 -> createPersona(scanner);
          case 2 -> createComentario(scanner);
          case 0 -> System.out.println("Saliendo...");
          default -> System.out.println("Opción inválida. Intenta de nuevo.");
        }
      } while (choice != 0);
    } finally {
      scanner.close();
      driver.close(); // Cierra la conexión al servidor de Neo4j
    }
  }

  // Persona Nodo
  private static void createPersona(Scanner scanner) {
    System.out.print("Ingresar nombre: ");
    String nombre = scanner.nextLine();
    System.out.print("Ingresar correo: ");
    String correo = scanner.nextLine();
    System.out.print("Ingresar edad: ");
    int edad = scanner.nextInt();
    scanner.nextLine();
    System.out.print("Ingresar ciudad: ");
    String ciudad = scanner.nextLine();

    try (Session session = driver.session()) {
      Query query = new Query(
          "CREATE (p:Persona {nombre: $nombre, correo: $correo, edad: $edad, ciudad: $ciudad})",
          org.neo4j.driver.Values.parameters("nombre", nombre, "correo", correo, "edad", edad, "ciudad", ciudad));
      session.run(query);
      System.out.println("Persona creada correctamente.");
    }
  }

  // Comentario Nodo
  private static void createComentario(Scanner scanner) {
    System.out.print("Ingresar correo de la persona que hace el comentario: ");
    String correo1 = scanner.nextLine();
    System.out.print("Ingresar correo de la persona que recibe el comentario: ");
    String correo2 = scanner.nextLine();
    System.out.print("Ingresar descripción del comentario: ");
    String descripcion = scanner.nextLine();

    try (Session session = driver.session()) {
      Query query = new Query(
          "MATCH (p1:Persona {correo: $correo1}), (p2:Persona {correo: $correo2}) " +
              "CREATE (p1)-[:COMENTARIO {descripcion: $descripcion}]->(p2)",
          org.neo4j.driver.Values.parameters("correo1", correo1, "correo2", correo2, "descripcion", descripcion));
      session.run(query);
      System.out.println("Comentario creado correctamente.");
    }
  }

}