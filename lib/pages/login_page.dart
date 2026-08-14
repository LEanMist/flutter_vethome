import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  bool esconderSenha = true;

  void mostrarMensagem(String mensagem){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem)
      ),
    );
  }

  void entrar(){
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if(email.isEmpty || senha.isEmpty){
      mostrarMensagem(
        'Preencha o e-mail e a senha.',
      );
      return;
    }
  }
  
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            const SizedBox(height: 150,),

            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/imagens/VetHome_logo_1.jpg',
                  width: 180,
                  height: 180,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 60),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 223, 187, 188),
                    hintText: 'Usuario',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(104, 68, 46, 0.5),
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 1, right: 8),
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 223, 187, 188),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Color.fromRGBO(104, 68, 46, 0.7),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              )
            ),

            const SizedBox(height: 20),

            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: TextField(
                  controller: _senhaController,
                  obscureText: esconderSenha,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color.fromARGB(255, 223, 187, 188),
                    hintText: 'Senha',
                    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(80),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(104, 68, 46, 0.5),
                        width: 1.5,
                      ),
                    ),
                    prefixIcon: Container(
                      margin: const EdgeInsets.only(left: 1, right: 8),
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 223, 187, 188),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Color.fromRGBO(104, 68, 46, 0.7),
                        size: 40,
                      ),
                    ),
                  ),
                ),
              )
            ),

            const SizedBox(height: 25,),

            ElevatedButton.icon(
              onPressed: entrar, 
              icon: Icon(Icons.login) ,
              label: const Text('Entrar')
            ),

             const SizedBox(height: 10),

             OutlinedButton.icon(
              onPressed: (){}, 
              icon: Icon(Icons.person_add) ,
              label: const Text('Criar usuário'),
            )

          ],
        ),
      )
    );
  }
}