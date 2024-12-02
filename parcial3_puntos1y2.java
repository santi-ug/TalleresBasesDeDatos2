/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 */

 package com.mycompany.parcial3bd2;

 import com.mongodb.client.MongoClient;
 import com.mongodb.client.MongoClients;
 import com.mongodb.client.MongoCollection;
 import com.mongodb.client.MongoDatabase;
 import com.mongodb.client.model.Filters;
 import java.util.Arrays;
 import java.util.Scanner;
 import org.bson.Document;
 import org.bson.conversions.Bson;
 
 /**
  *
  * @author Santi
  */
 public class Puntos1y2 {
 
     public static void main(String[] args) {
         String uri = "mongodb://localhost:27017";
         MongoClient mongoClient = MongoClients.create(uri);
         MongoDatabase db = mongoClient.getDatabase("parcial3");
         System.out.println("Conexion Exitosa");
         
         // Collections
         MongoCollection<Document> productos = db.getCollection("Productos");
         MongoCollection<Document> pedidos = db.getCollection("Pedidos");
         MongoCollection<Document> detallePedidos = db.getCollection("Detalle_Pedidos");
 
         
         // Menu
         Scanner scanner = new Scanner(System.in);
         int choice;
         do {
             System.out.println("\n=== CRUD Menu ===");
             System.out.println("1. Create Productos");
             System.out.println("2. Create Pedidos");
             System.out.println("3. Create Detalle_Pedidos");
             System.out.println("4. Read Collections");
             System.out.println("5. Update Collections");
             System.out.println("6. Delete Collections");
             System.out.println("7. Consultar productos con precio > 20 USD");
             System.out.println("8. Consultar pedidos con total > 100 USD");
             System.out.println("9. Consultar pedidos con producto010 en detalles");
             System.out.println("0. Salir");
             System.out.print("Opcion Seleccionada: ");
             choice = scanner.nextInt();
             scanner.nextLine(); // Consume newline
 
             switch (choice) {
                 case 1 -> createProducto(productos, scanner);
                 case 2 -> createPedido(pedidos, scanner);
                 case 3 -> createDetallePedido(detallePedidos, scanner);
                 case 4 -> readCollection(productos, pedidos, detallePedidos);
                 case 5 -> updateCollection(productos, pedidos, detallePedidos, scanner);
                 case 6 -> deleteCollection(productos, pedidos, detallePedidos, scanner);
                 case 7 -> getProductosMayorA20(productos);
                 case 8 -> getPedidosMayorA100(pedidos);
                 case 9 -> getPedidosConProducto010(detallePedidos, pedidos);
                 case 0 -> System.out.println("Saliendo...");
                 default -> System.out.println("No es una ocpión válida");
             }
         } while (choice != 0);
 
         mongoClient.close();
         scanner.close();
     }
     
     // CRUD - PUNTO 1
     
     // CREATE
     private static void createProducto(MongoCollection<Document> collection, Scanner scanner) {
         long count = collection.countDocuments();
         String productoId = "producto" + String.format("%03d", count + 1);
 
         System.out.print("Ingresar nombre del producto: "); String nombre = scanner.nextLine();
         System.out.print("Ingresar descripcion del producto: "); String desc = scanner.nextLine();
         System.out.print("Ingresar precio del producto: "); double precio = scanner.nextDouble();
         System.out.print("Ingresar stock del producto: "); int stock = scanner.nextInt();
         scanner.nextLine(); 
 
         Document producto = new Document("_id", productoId)
                 .append("nombre", nombre)
                 .append("descripcion", desc)
                 .append("precio", precio)
                 .append("stock", stock);
         collection.insertOne(producto);
         System.out.println("Producto agregado");
     }
     
     private static void createPedido(MongoCollection<Document> collection, Scanner scanner) {
         long count = collection.countDocuments();
         String pedidoId = "pedido" + String.format("%03d", count + 1);
 
         System.out.print("Ingresar nombre del cliente: "); String cliente = scanner.nextLine();
         System.out.print("Ingresar fecha del pedido (YYYY-MM-DD): "); String fecha_pedido = scanner.nextLine();
         System.out.print("Ingresar estado del pedido: "); String estado = scanner.nextLine();
         System.out.print("Ingresar total del pedido: "); double total = scanner.nextDouble();
         scanner.nextLine(); 
 
         Document pedido = new Document("_id", pedidoId)
                 .append("cliente", cliente)
                 .append("fecha_pedido", fecha_pedido)
                 .append("estado", estado)
                 .append("total", total);
         collection.insertOne(pedido);
         System.out.println("Pedido agregado");
     }
     
     private static void createDetallePedido(MongoCollection<Document> collection, Scanner scanner) {
         long count = collection.countDocuments();
         String detalleId = "detalle" + String.format("%03d", count + 1);
 
         System.out.print("Ingresar ID del pedido: "); String pedidoId = scanner.nextLine();
         System.out.print("Ingresar ID del producto: "); String productoId = scanner.nextLine();
         System.out.print("Ingresar cantidad: "); int cantidad = scanner.nextInt();
         System.out.print("Ingresar precio unitario: "); double precioUnitario = scanner.nextDouble();
         scanner.nextLine();
 
         Document detallePedido = new Document("_id", detalleId)
                 .append("pedido_id", pedidoId)
                 .append("producto_id", productoId)
                 .append("cantidad", cantidad)
                 .append("precio_unitario", precioUnitario);
 
         collection.insertOne(detallePedido);
         System.out.println("Detalle del pedido agregado");
     }
 
     
     // READ 
     private static void readCollection(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos) {
         System.out.println("=== Productos ===");
         productos.find().forEach(doc -> System.out.println(doc.toJson()));
 
         System.out.println("\n=== Pedidos ===");
         pedidos.find().forEach(doc -> System.out.println(doc.toJson()));
 
         System.out.println("\n=== Detalle_Pedidos ===");
         detallePedidos.find().forEach(doc -> System.out.println(doc.toJson()));
     }
     
     
     // UPDATE 
     private static void updateCollection(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos, Scanner scanner) {
         System.out.print("Escribe la coleccion que quieres actualizar (Productos, Pedidos, Detalle_Pedidos): ");
         String collectionName = scanner.nextLine();
 
         switch (collectionName) {
             case "Productos" -> updateProducto(productos, scanner);
             case "Pedidos" -> updatePedido(pedidos, scanner);
             case "Detalle_Pedidos" -> updateDetallePedido(detallePedidos, scanner);
             default -> System.out.println("Coleccion invalida.");
         }
     }
 
     private static void updateProducto(MongoCollection<Document> collection, Scanner scanner) {
         System.out.print("Ingresar ID del producto: "); String productId = scanner.nextLine();
         System.out.print("Ingresar nombre nuevo del producto: "); String newNombre = scanner.nextLine();
         System.out.print("Ingresar descripcion nueva del producto: "); String newDesc = scanner.nextLine();
         System.out.print("Ingresar precio nuevo del producto: "); double newPrecio = scanner.nextDouble();
         System.out.print("Ingresar stock nuevo del producto: "); int newStock = scanner.nextInt();
         scanner.nextLine();
 
         Bson filter = Filters.eq("_id", productId);
         Bson updateOperation = new Document("$set", new Document("nombre", newNombre)
                 .append("descripcion", newDesc)
                 .append("precio", newPrecio)
                 .append("stock", newStock));
         collection.updateOne(filter, updateOperation);
         System.out.println("Producto actualizado");
     }
 
     private static void updatePedido(MongoCollection<Document> collection, Scanner scanner) {
         System.out.print("Ingresar ID del pedido: "); String pedidoId = scanner.nextLine();
         System.out.print("Ingresar nombre nuevo del cliente: "); String newCliente = scanner.nextLine();
         System.out.print("Ingresar nueva fecha del pedido (YYYY-MM-DD): "); String newFechaPedido = scanner.nextLine();
         System.out.print("Ingresar nuevo estado del pedido: "); String newEstado = scanner.nextLine();
         System.out.print("Ingresar total nuevo del pedido: "); double newTotal = scanner.nextDouble();
         scanner.nextLine(); 
 
         Bson filter = Filters.eq("_id", pedidoId);
         Bson updateOperation = new Document("$set", new Document("cliente", newCliente)
                 .append("fecha_pedido", newFechaPedido)
                 .append("estado", newEstado)
                 .append("total", newTotal));
         collection.updateOne(filter, updateOperation);
         System.out.println("Pedido actualizado");
     }
 
 
     private static void updateDetallePedido(MongoCollection<Document> collection, Scanner scanner) {
         System.out.print("Ingresar ID del detalle: "); String detalleId = scanner.nextLine();
         System.out.print("Ingresar nuevo ID del pedido: "); String newPedidoId = scanner.nextLine();
         System.out.print("Ingresar nuevo ID del producto: "); String newProductoId = scanner.nextLine();
         System.out.print("Ingresar nueva cantidad: "); int newCantidad = scanner.nextInt();
         System.out.print("Ingresar nuevo precio unitario: "); double newPrecioUnitario = scanner.nextDouble();
         scanner.nextLine(); // Consumir salto de línea
 
         Bson filter = Filters.eq("_id", detalleId);
         Bson updateOperation = new Document("$set", new Document("pedido_id", newPedidoId)
                 .append("producto_id", newProductoId)
                 .append("cantidad", newCantidad)
                 .append("precio_unitario", newPrecioUnitario));
         collection.updateOne(filter, updateOperation);
         System.out.println("Detalle del pedido actualizado");
     }
     
     
     // DELETE
     private static void deleteCollection(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos, Scanner scanner) {
         System.out.print("Ingresar coleccion para eliminar (Productos, Pedidos, Detalle_Pedidos): ");
         String collectionName = scanner.nextLine();
 
         switch (collectionName) {
             case "Productos" -> deleteProducto(productos, scanner);
             case "Pedidos" -> deletePedido(pedidos, scanner);
             case "Detalle_Pedidos" -> deleteDetallePedido(detallePedidos, scanner);
             default -> System.out.println("Coleccion invalida");
         }
     }
 
     private static void deleteProducto(MongoCollection<Document> collection, Scanner scanner) {
         System.out.print("Ingresar ID del producto a eliminar: ");
         String productId = scanner.nextLine();
 
         Bson filter = Filters.eq("_id", productId);
         collection.deleteOne(filter);
         System.out.println("Producto eliminado correctamente.");
     }
 
 
     private static void deletePedido(MongoCollection<Document> collection, Scanner scanner) {
         System.out.print("Ingresar ID del pedido a eliminar: ");
         String pedidoId = scanner.nextLine();
 
         Bson filter = Filters.eq("_id", pedidoId);
         collection.deleteOne(filter);
         System.out.println("Pedido eliminado correctamente.");
     }
 
 
     private static void deleteDetallePedido(MongoCollection<Document> collection, Scanner scanner) {
         System.out.print("Ingresar ID del detalle a eliminar: ");
         String detalleId = scanner.nextLine();
 
         Bson filter = Filters.eq("_id", detalleId);
         collection.deleteOne(filter);
         System.out.println("Detalle del pedido eliminado correctamente.");
     }
 
     
     // CONSULTAS - PUNTO 2
     // CONSULTA 1
     private static void getProductosMayorA20(MongoCollection<Document> productos) {
         System.out.println("=== Productos con precio mayor a 20 USD ===");
         productos.find(Filters.gt("precio", 20)).forEach(doc -> System.out.println(doc.toJson()));
     }
 
     // CONSULTA 2
     private static void getPedidosMayorA100(MongoCollection<Document> pedidos) {
         System.out.println("=== Pedidos con total mayor a 100 USD ===");
         pedidos.find(Filters.gt("total", 100)).forEach(doc -> System.out.println(doc.toJson()));
     }
 
     // CONSULTA 3
     private static void getPedidosConProducto010(MongoCollection<Document> detallePedidos, MongoCollection<Document> pedidos) {
         System.out.println("=== Pedidos con el producto010 en sus detalles ===");
         Iterable<Document> detalles = detallePedidos.find(Filters.eq("producto_id", "producto010"));
 
         detalles.forEach(detalle -> {
             String pedidoId = detalle.getString("pedido_id");
             pedidos.find(Filters.eq("_id", pedidoId)).forEach(doc -> System.out.println(doc.toJson()));
         });
     }
 
 }
 