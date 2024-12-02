/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package com.mycompany.parcial3bd2;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.Filters;
import org.bson.Document;
import org.bson.conversions.Bson;

import java.util.Scanner;

/**
 *
 * @author Santi
 */
public class Puntos3y4 {

  public static void main(String[] args) {
    String uri = "mongodb://localhost:27017";
    MongoClient mongoClient = MongoClients.create(uri);
    MongoDatabase db = mongoClient.getDatabase("parcial3_desnormalizado");
    System.out.println("Conexion Exitosa");

    // Collection
    MongoCollection<Document> reservas = db.getCollection("Reservas");

    // Menu
    Scanner scanner = new Scanner(System.in);
    int choice;
    do {
      System.out.println("\n=== CRUD Menu ===");
      System.out.println("1. Create Reserva");
      System.out.println("2. Read Reservas");
      System.out.println("3. Update Reserva");
      System.out.println("4. Delete Reserva");
      System.out.println("5. Consultar habitaciones reservadas tipo Sencilla");
      System.out.println("6. Consultar sumatoria total de reservas pagadas");
      System.out.println("7. Consultar reservas con precio_noche > 100 USD");
      System.out.println("0. Salir");
      System.out.print("Opcion Seleccionada: ");
      choice = scanner.nextInt();
      scanner.nextLine(); // Consume newline

      switch (choice) {
        case 1 -> createReserva(reservas, scanner);
        case 2 -> readReservas(reservas);
        case 3 -> updateReserva(reservas, scanner);
        case 4 -> deleteReserva(reservas, scanner);
        case 5 -> getReservasTipoSencilla(reservas);
        case 6 -> getSumatoriaReservasPagadas(reservas);
        case 7 -> getReservasConPrecioMayorA100(reservas);
        case 0 -> System.out.println("Saliendo...");
        default -> System.out.println("No es una opción válida.");
      }
    } while (choice != 0);

    mongoClient.close();
    scanner.close();
  }

  // CREATE
  private static void createReserva(MongoCollection<Document> collection, Scanner scanner) {
    long count = collection.countDocuments();
    String reservaId = "reserva" + String.format("%03d", count + 1);

    System.out.print("Ingresar nombre del cliente: ");
    String cliente = scanner.nextLine();
    System.out.print("Ingresar tipo de habitacion: ");
    String tipoHabitacion = scanner.nextLine();
    System.out.print("Ingresar precio por noche de la habitacion: ");
    double precioNoche = scanner.nextDouble();
    scanner.nextLine();
    System.out.print("Ingresar fecha de la reserva (YYYY-MM-DD): ");
    String fechaReserva = scanner.nextLine();
    System.out.print("¿La reserva está pagada? (true/false): ");
    boolean pagada = scanner.nextBoolean();
    System.out.print("Ingresar total de la reserva: ");
    double total = scanner.nextDouble();
    scanner.nextLine();

    Document habitacion = new Document("tipo", tipoHabitacion).append("precio_noche", precioNoche);
    Document reserva = new Document("_id", reservaId).append("cliente", cliente).append("habitacion", habitacion)
        .append("fecha_reserva", fechaReserva).append("pagada", pagada).append("total", total);

    collection.insertOne(reserva);
    System.out.println("Reserva agregada correctamente.");
  }

  // READ
  private static void readReservas(MongoCollection<Document> collection) {
    System.out.println("=== Reservas ===");
    collection.find().forEach(doc -> System.out.println(doc.toJson()));
  }

  // UPDATE
  private static void updateReserva(MongoCollection<Document> collection, Scanner scanner) {
    System.out.print("Ingresar ID de la reserva: ");
    String reservaId = scanner.nextLine();
    System.out.print("Ingresar nombre nuevo del cliente: ");
    String newCliente = scanner.nextLine();
    System.out.print("Ingresar nuevo tipo de habitacion: ");
    String newTipoHabitacion = scanner.nextLine();
    System.out.print("Ingresar nuevo precio por noche de la habitacion: ");
    double newPrecioNoche = scanner.nextDouble();
    scanner.nextLine();
    System.out.print("Ingresar nueva fecha de la reserva (YYYY-MM-DD): ");
    String newFechaReserva = scanner.nextLine();
    System.out.print("¿La reserva está pagada? (true/false): ");
    boolean newPagada = scanner.nextBoolean();
    System.out.print("Ingresar nuevo total de la reserva: ");
    double newTotal = scanner.nextDouble();
    scanner.nextLine();

    Document newHabitacion = new Document("tipo", newTipoHabitacion).append("precio_noche", newPrecioNoche);
    Bson filter = Filters.eq("_id", reservaId);
    Bson updateOperation = new Document("$set", new Document("cliente", newCliente).append("habitacion", newHabitacion)
        .append("fecha_reserva", newFechaReserva).append("pagada", newPagada).append("total", newTotal));

    collection.updateOne(filter, updateOperation);
    System.out.println("Reserva actualizada correctamente.");
  }

  // DELETE
  private static void deleteReserva(MongoCollection<Document> collection, Scanner scanner) {
    System.out.print("Ingresar ID de la reserva a eliminar: ");
    String reservaId = scanner.nextLine();

    Bson filter = Filters.eq("_id", reservaId);
    collection.deleteOne(filter);
    System.out.println("Reserva eliminada correctamente.");
  }

  // CONSULTAS
  // CONSULTA 1
  private static void getReservasTipoSencilla(MongoCollection<Document> collection) {
    System.out.println("=== Habitaciones reservadas de tipo Sencilla ===");
    collection.find(Filters.eq("habitacion.tipo", "Sencilla")).forEach(doc -> System.out.println(doc.toJson()));
  }

  // CONSULTA 2
  private static void getSumatoriaReservasPagadas(MongoCollection<Document> collection) {
    System.out.println("=== Sumatoria total de reservas pagadas ===");
    double sumatoria = collection.find(Filters.eq("pagada", true)).into(new java.util.ArrayList<>())
        .stream().mapToDouble(doc -> doc.getDouble("total")).sum();
    System.out.println("Total de reservas pagadas: $" + sumatoria);
  }

  // CONSULTA 3
  private static void getReservasConPrecioMayorA100(MongoCollection<Document> collection) {
    System.out.println("=== Reservas con precio por noche mayor a 100 USD ===");
    collection.find(Filters.gt("habitacion.precio_noche", 100)).forEach(doc -> System.out.println(doc.toJson()));
  }
}
