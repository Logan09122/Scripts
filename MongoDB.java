import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.URL;
import java.net.URLConnection;
import java.time.LocalDate;
import java.io.BufferedReader;
import java.io.File;
 
public class MongoDB 
{
    public static void main( String[] args ) throws IOException, InterruptedException
    {
        boolean isConnected = false;
        //Prueba la conexion a internet primero hasta que logre la conexion hace el backup
        while (!isConnected) {
            try {
                URI uri = new URI("https://www.google.com");
                URL url = uri.toURL(); 
                URLConnection connection = url.openConnection();
                connection.connect(); // Intenta conectar
                System.out.println("Conexion con exito. Realizando Backup...");
                isConnected = true; 
            } catch (Exception e) {
                System.out.println("No hay conexion a internet.Reintentando...");
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException e2) {
                    System.err.println(e2);
                }
            }
        }        

        String Actualpath = new Paths().MakeDir(); //obtiene el AbsolutePath de la fecha Actual
        int retries = 3; 
        boolean success = false;
        //Aqui intentara hasta 3 veces para completar el backup
        for (int i = 0; i < retries; i++) {
            if (DoCommands(Actualpath, MongoCommand)) {
                success = true;
                break;
            } else {
                System.out.println("Intento fallido al ejecutar MongoDump. Reintentando...");
                Thread.sleep(3000); 
            }
        }
        //Si completa el backup correctamente ejecuta los demas comandos
        if (success) {
            DoCommands(Actualpath, Compress);
            DoCommands(Actualpath, DeleteDumpDir);
        } else {
            System.out.println("Error al ejecutar MongoCommand despues de " + retries + " intentos.");
        }
    }

    //Ejecuta los comandos para el backup,compresion y eliminacion de la carpeta del dump
    private static boolean DoCommands(String path,String command) throws IOException, InterruptedException{
        ProcessBuilder process = new ProcessBuilder("cmd.exe","/c",command);
        process.redirectErrorStream(true); 
        process.directory(new File(path));
        Process output = process.start();

        // Lee y muestra la salida del comando 
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(output.getInputStream()))) {
            String line;
            while ((line = reader.readLine()) != null) {
                System.out.println(line); //Muestra el progreso
            }
        }
        //Espera a que termine el proceso
        int exitCode = output.waitFor(); 
        if (exitCode != 0) {
            System.out.println("Hubo un error al ejecutar: " + command);
            return false;
        }
        return true;
    }
    private static final String DeleteDumpDir = "rmdir /s /q " + "" + "dump";
    private static final String Compress = "rar a backUp dump";
    private static final String MongoCommand = "mongodump --uri=mongodb:<url>";
}

class Paths{
    private LocalDate ActualDate = LocalDate.now();
    private int year = ActualDate.getYear();
    private int month = ActualDate.getMonthValue();
    private static final String Backup_Path = "C:/";
    private String PathDaily;

    int lastDayOfMonth = ActualDate.lengthOfMonth();
    int currentDay = ActualDate.getDayOfMonth(); // dia actual del mes

    //Crea carpetas y subcarpetas para el respaldo verificando la fecha del dump
    public String MakeDir(){
        File yearDir = new File(Backup_Path, String.valueOf(year));
        File monthDir = new File(yearDir, String.valueOf(month));
        File dayDir = new File(monthDir, String.valueOf(ActualDate));
        // Crear estructura de directorios si no existe
        if (!dayDir.exists()) {
            dayDir.mkdirs();
            //Elimina todos los backups anteriores en el mes, dejando solo el del ultimo dia
            //o si es dia lunes igual las elimina dejando solo el del dia actual, empezando de nuevo
            if (currentDay == lastDayOfMonth || (ActualDate.getDayOfWeek().toString().equals("MONDAY") && monthDir.exists())) {
                DeleteBackups(monthDir, ActualDate);
            }
            System.out.println("Carpeta creada correctamente");
        } else {
            System.out.println("La carpeta ya existe: " + dayDir.getAbsolutePath());
        }
        //obtiene y retorna el path de la carpeta creada con ese dia
        PathDaily = dayDir.getPath();
        return PathDaily;
    }

    public static void DeleteBackups(File monthDir, LocalDate currentDate){
        //obtiene todos los directorios de la carpeta actual del mes
        File [] dir = monthDir.listFiles();
        if (dir != null) {
            for(int i=0;i <dir.length;i++){
                //verifica si es un directorio y ademas si no es igual al date actual. 
                //Despues lo elimina de manera recursiva con el cmd en la iteracion actual
                if (dir[i].isDirectory() && !dir[i].getName().equals(currentDate.toString())) {
                    try {
                        ProcessBuilder process = new ProcessBuilder("cmd.exe", "/c", "rmdir /s /q " + dir[i].getAbsolutePath());
                        process.start();
                    } catch (Exception e) {
                        System.err.println(e);
                        System.out.println("No se ha logrado eliminar la carpeta: " + dir[i]);
                    }
                }
            }
        }
    }
}