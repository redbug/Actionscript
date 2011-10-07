
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class test5_s {
	private static final int PORT = 1234; //port 
	private static final int POLICY_SERVER_PORT = 3333;
	
	private static List<Socket> list = new ArrayList<Socket>(); // 
	
	public static final String POLICY_REQUEST = "<policy-file-request/>"; 
	public static final String POLICY_XML = "<?xml version=\"1.0\"?>" + 
											"<cross-domain-policy>" + 
											"<allow-access-from domain=\"*\" to-ports=\"1234\" />" + 
											"</cross-domain-policy>";   
	
	
	private ExecutorService exec;
	private ServerSocket server;
	
	public static void main(String[] args) {
		new test5_s();
	
	}
	public test5_s() {
	
		try {
		
			server = new ServerSocket(PORT);
//			policyServer = new ServerSocket(POLICY_SERVER_PORT);
			
			exec = Executors.newCachedThreadPool();
			System.out.println("server open!");
			Socket client = null;
			
			exec.execute(new PolicyServer());
			
			while (true) {
				
				client = server.accept(); // client connect~
				list.add(client);
				exec.execute(new Client(client));
				
			
			}
		
		} catch (IOException e) {
		
			e.printStackTrace();
		
		}
	
	}
	
	class PolicyServer extends Thread {
		
		private ServerSocket policyServer;
		
		public PolicyServer()
		{
			try {
				policyServer = new ServerSocket(POLICY_SERVER_PORT);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			start();
		}
		
		public void run(){
			
				
				try {
					System.out.println("listening");
					Socket socket = policyServer.accept();
					
					System.out.println("after listening");
					
					BufferedReader br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
					
//					System.out.println(read(br));
					
					PrintWriter pw = new PrintWriter(socket.getOutputStream(), true);
					
					if(read(br).trim().equals(POLICY_REQUEST)){
						
						System.out.println("send PolicyFile in PolicyServer");
						pw.write(POLICY_XML + "\0");
						pw.flush();
					}
					
					
					
//					
//					while ( (msg = br.readLine()) != null)
//					{
//						
//						if(msg.trim().equals(POLICY_REQUEST)){
//							System.out.println("br: " + msg);
//							pw.print(POLICY_XML + "\u0000");
//						}	
//					}
					
					pw.close();
					
					
//					while ((msg = br.readLine()) != null) {
//						
//						System.out.println("msg:" + msg);
//						if(msg.trim().equals(POLICY_REQUEST)){
//							
//							System.out.println(msg);	
//								
//System.out.println(POLICY_XML + '\0');							
//							pw.print(POLICY_XML + "\0");
//							
//							break;
//						}
//					}
					
//					pw.close();
					socket.close();
					
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				} finally{
					
				}
			
		}
		
		
		   protected String read(BufferedReader br) {
		        StringBuffer buffer = new StringBuffer();
		        int codePoint;
		        boolean zeroByteRead = false;
		        
		        try {
		            do {
		                codePoint = br.read();

		                if (codePoint == 0) {
		                    zeroByteRead = true;
		                }
		                else if (Character.isValidCodePoint(codePoint)) {
		                    buffer.appendCodePoint(codePoint);
		                }
		            }
		            while (!zeroByteRead && buffer.length() < 200);
		        }
		        catch (Exception e) {
//		            debug("Exception (read): " + e.getMessage());
		        }
		        
		        return buffer.toString();
		    }
		
		
		
		
		
		
	}
	
	
	
	
	
	
	
	static class Client implements Runnable {
	private Socket socket;
	
	private BufferedReader br;
	
	private PrintWriter pw;
	
	private String msg;
	
	public Client(Socket socket) throws IOException {
	
		this.socket = socket;
		
		br = new BufferedReader(new InputStreamReader(socket.getInputStream()));
		
		msg = "(" + this.socket.getPort() + ")進入聊天室!當前聊天室有"+list.size() + "人";
		
		sendAll();
	
	}
	
	public void run() {
	
		try {
		
			while ((msg = br.readLine()) != null) {
			
				if (msg.trim().equals("bye")) {
				
					list.remove(socket);
					
					br.close();
					
					pw.close();
					
					msg = "(" + socket.getPort() + ")離開聊天室!當前聊天室有" + list.size() + "人";
					
					socket.close();
					
					sendAll();
					
					break;
				
				}else if(msg.trim().equals(POLICY_REQUEST))
				{
//					System.out.println("nothing");
//					msg="<?xml version=\"1.0\"?><cross-domain-policy><allow-access-from domain=\"*\" to-ports=\"*\" /></cross-domain-policy>\0";
//					send(msg);
					sendPolicyFile(msg);
				}
				else {
				
					msg = "(" + socket.getPort() + ")說：" + msg;
					sendAll();
				
				}
			
			}
		
		} catch (IOException e) {
		
		e.printStackTrace();
		
		}
	
	}
		
	private void sendAll() throws IOException {
		System.out.println(msg);
	
		for (Socket client : list) {
		
		pw = new PrintWriter(client.getOutputStream(), true);
		
		pw.println(msg);
	
		}
	
	}
	private void send(String msg) throws IOException {
		System.out.println(msg);	
		pw = new PrintWriter(socket.getOutputStream(), true);		
		pw.println(msg);				
	}
	
	private void sendPolicyFile(String msg) throws IOException
	{
		System.out.println(msg);
		System.out.println("send Policy_XML");
		pw = new PrintWriter(socket.getOutputStream(), true);	
		pw.write(POLICY_XML + "\0");
//		pw.flush();
	}
	
	
	}
}

