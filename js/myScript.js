/**
 * Esta función muestra un formulario de login (para fetch)
 * El botón enviar del formulario deberá invocar a la función doLogin
 * Modifica el tag div con id main en el html
 */

var xml;
var userFullName = '';
var userKey = '';
function showLogin(){
  let formhtml = `
    <form onsubmit="doLogin(); return false;">  <!-- Añadido onsubmit -->
      <label>User</label><br>
      <input type="text" id="user" name="user"><br>
      <label>Password</label><br>
      <input type="password" id="password" name="password"><br>
      <button type="submit">Ingresar</button> 
      <p id="mensaje"></p>
    </form>
  `;
  document.getElementById('main').innerHTML = formhtml;
}
/**
 * Esta función recolecta los valores ingresados en el formulario
 * y los envía al CGI login.pl
 * La respuesta del CGI es procesada por la función loginResponse
 */
function doLogin(){
  let user = document.getElementById('user').value;
  let password = document.getElementById('password').value;
  console.log(user);
  console.log(password);
  console.log('URL:', `cgi-bin/login.pl?user=${user}&password=${password}`);
  let url = 'cgi-bin/login.pl?user='+user+'&password='+password;
  console.log(url);

  fetch(url)
    .then(response => {
      console.log("Respuesta del servidor recibida...");
      return response.text();
    })
    .then(data => {
      console.log("Procesando respuesta...");
      let xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("XML recibido:", data);  // Verificar los datos que estamos recibiendo

      let sessionID = xml.getElementsByTagName('session_id')[0]?.textContent;

      if (sessionID) {
        console.log("Sesión encontrada. Almacenando session_id...");
        // Almacenar el session_id en sessionStorage
        sessionStorage.setItem('session_id', sessionID);
        loginResponse(xml);  // Llamamos a la función de respuesta con los datos XML
      } else {
        console.log("No se encontró session_id. Datos incorrectos.");
        document.getElementById('mensaje').innerHTML = "Datos incorrectos";
        showLogin();
      }
    })
    .catch(error => {
      console.log("Error en la solicitud de login:", error);  // Verificar si ocurre un error en la solicitud
    });

}
/**
 * Esta función recibe una respuesta en un objeto XML
 * Si la respuesta es correcta, recolecta los datos del objeto XML
 * e inicializa la variable userFullName y userKey (e usuario)
 * termina invocando a la funcion showLoggedIn.
 * Si la respuesta es incorrecta, borra los datos del formulario html
 * indicando que los datos de usuario y contraseña no coinciden.
 */
function loginResponse(xml) {
  var usuario = xml.getElementsByTagName('user'); // Obtiene el nodo 'user'
  
  if (usuario.length === 1) {
    var owner = usuario[0].getElementsByTagName('owner')[0]?.textContent; // Agregar seguridad contra valores undefined
    var firstName = usuario[0].getElementsByTagName('firstName')[0]?.textContent;
    var lastName = usuario[0].getElementsByTagName('lastName')[0]?.textContent;

    console.log(owner);
    console.log(firstName);
    console.log(lastName);

    if (owner && firstName && lastName) {
      userFullName = `${firstName} ${lastName}`;
      userKey = owner;
      showLoggedIn(); // Esta función debería mostrar el contenido para un usuario logueado
    } else {
      document.getElementById('mensaje').innerHTML = "Datos incorrectos";
      showLogin();
    }
  } else {
    document.getElementById('mensaje').innerHTML = "Datos incorrectos";
    showLogin();
  }
  
  // Agregar estas líneas para ver el contenido del XML y el mensaje
  console.log('Validación del XML:', xml);
  console.log('Mensaje:', document.getElementById('mensaje').innerHTML);
}
/**
 * esta función usa la variable userFullName, para actualizar el
 * tag con id userName en el HTML
 * termina invocando a las functiones showWelcome y showMenuUserLogged
 */
function showLoggedIn(){
  document.getElementById('userName').innerHTML = userFullName;
  showWelcome();
  showMenuUserLogged();
}
/**
 * Esta función crea el formulario para el registro de nuevos usuarios
 * el fomulario se mostrará en tag div con id main.
 * La acción al presionar el bontón de Registrar será invocar a la 
 * función doCreateAccount
 * */
function showCreateAccount(){
  let formhtml = `
    <form onsubmit="doCreateAccount(); return false;">  <!-- Añadido onsubmit -->
      <label>Username</label><br>
      <input type="text" id="username" name="user"><br>
      <label>Firstname</label><br>
      <input type="text" id="firstname" name="firstname"><br>
      <label>Lastname</label><br>
      <input type="text" id="lastname" name="lastname"><br>
      <label>Password</label><br>
      <input type="password" id="password" name="password"><br>
      <button type="submit">Registrar</button> 
      <p id="mensaje"></p>
    </form>
  `;
  document.getElementById('main').innerHTML = formhtml;


}

/* Esta función extraerá los datos ingresados en el formulario de
 * registro de nuevos usuarios e invocará al CGI register.pl
 * la respuesta de este CGI será procesada por loginResponse.
 */
function doCreateAccount(){
  let user = document.getElementById('username').value;
  let firstName = document.getElementById('firstname').value;
  let lastName = document.getElementById('lastname').value;
  let password = document.getElementById('password').value;
  console.log("datos recogidos:",user,firstname,lastname,password);
  let url = 'cgi-bin/register.pl?userName='+user+'&password='+password+'&firstName='+
    firstName+'&lastName='+lastName;
  console.log(url);

  
  // Realizar la solicitud al CGI 'register.pl'
  fetch(url)
    .then(response => response.text())  // Obtener la respuesta como texto
    .then(data => {
      console.log("Respuesta del servidor:", data);
      let xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("XML recibido:", xml);

      // Procesar la respuesta XML para verificar si la creación de cuenta fue exitosa
      let message = xml.getElementsByTagName('message')[0]?.textContent;

      if (message === 'Faltan datos') {
        console.log("Error: Faltan datos.");
        document.getElementById('mensaje').innerHTML = "Faltan datos. Por favor, complete todos los campos.";
      } else {
        // En este punto, si no falta información, se asume que la cuenta fue creada correctamente
        console.log("Cuenta creada exitosamente.");
        document.getElementById('mensaje').innerHTML = "Cuenta creada con éxito.";
        loginResponse(xml);
        // Opcional: Redirigir al usuario al login o mostrar un mensaje de éxito
        //showLogin();  // Esto puede ser reemplazado por la lógica para redirigir a la página de login si es necesario
      }
    })
    .catch(error => {
      console.log("Error al registrar la cuenta:", error);
      document.getElementById('mensaje').innerHTML = "Ocurrió un error. Inténtelo de nuevo.";
    });
}
/*
 * Esta función invocará al CGI list.pl usando el nombre de usuario 
 * almacenado en la variable userKey
 * La respuesta del CGI debe ser procesada por showList
 */
function doList(){
  let owner = userKey;  // 'userKey' es el propietario (owner)
  let sessionID = sessionStorage.getItem('session_id');  // Obtener el session_id desde sessionStorage
  console.log("sesion id: ", sessionID);
  console.log("Este es el owner que será enviado al CGI", owner);
  let url = `cgi-bin/list.pl?owner=${owner}&session_id=${sessionID}`;
  console.log("este cgi se usara",url);

  let promise = fetch(url);
  promise.then(response => response.text())
    .then(data => {
      let xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("XML recibido:", xml);
      showList(xml);  // Mostrar los artículos de la lista
    }).catch(error => {
      console.log('Error :', error);
    });
}
/**
 * Esta función recibe un objeto XML con la lista de artículos de un usuario
 * y la muestra incluyendo:
 * - Un botón para ver su contenido, que invoca a doView.
 * - Un botón para borrarla, que invoca a doDelete.
 * - Un botón para editarla, que invoca a doEdit.
 * En caso de que lista de páginas esté vacia, deberá mostrar un mensaje
 * indicándolo.
 */
function showList(xml) {
  console.log("Se ingreso a la función showList y se recibio", xml);
  var articulos = xml.getElementsByTagName('article');
  var owners = xml.getElementsByTagName('owner');
  var titulos = xml.getElementsByTagName('title');
  console.log("artículo", articulos);
  console.log("tamaño de la colección", articulos.length);
  var numArticulos = articulos.length;
  var listhtml = "";

  if (numArticulos == 0) {
    console.log("No tiene ningún artículo");
    listhtml = `<p>No tiene artículos</p>`;
  } else {
    console.log("Sí tiene artículos");
    console.log("Esto son", titulos);
    console.log("Primer owner y title", owners[0].textContent, titulos[0].textContent);
    console.log(typeof(owners[0].textContent));
    
    listhtml = "<ol>";
    for (let i = 0; i < numArticulos; i++) {
      // Eliminamos los caracteres '#' al principio del título para la visualización
      let displayTitle = titulos[i].textContent.replace(/^#+/, '');  // Elimina los '#' al inicio del título

      // Codificamos el título solo cuando lo pasamos a los botones
      let safeTitle = encodeURIComponent(titulos[i].textContent);

      listhtml += `<li>${displayTitle}` +
        `<button onclick="doView('${owners[i].textContent}', '${safeTitle}')">View</button>` +
        `<button onclick="doDelete('${owners[i].textContent}', '${safeTitle}')">Delete</button>` +
        `<button onclick="doEdit('${owners[i].textContent}', '${safeTitle}')">Edit</button>` +
        "</li>\n";
    }
    listhtml += "</ol>";
  }

  document.getElementById('main').innerHTML = listhtml;
}

/**
 * Esta función deberá generar un formulario para la creación de un nuevo
 * artículo, el formulario deberá tener dos botones
 * - Enviar, que invoca a doNew 
 * - Cancelar, que invoca doList
 */
function showNew() {
  var formhtml = "";
  formhtml = `
    <form onsubmit="doNew(); return false;">  <!-- Añadido onsubmit -->
      <label>Título</label>
      <input type="text" id="titulo" name="titulo" value=""><br>
      <label>Texto</label>
      <textarea style="width:355px; height:200px" id="cuadrotext" name="texto"></textarea><br>
      <button type="submit">Enviar</button>
      <button type="button" onclick="doList()">Cancelar</button>
    </form>
  `;
  document.getElementById('main').innerHTML = formhtml;
}

/*
 * Esta función invocará new.pl para resgitrar un nuevo artículo
 * los datos deberán ser extraidos del propio formulario
 * La acción de respuesta al CGI deberá ser una llamada a la 
 * función responseNew
 */
function doNew() {
  let title  = document.getElementById('titulo').value.trim();  // Trimming los espacios
  let texto = document.getElementById('cuadrotext').value.trim();  // Trimming los espacios
  console.log("Datos recogidos:", title, texto);

  if (title === '' || texto === '') {
    console.log("Algunos campos están vacíos.");
    alert("Por favor, complete todos los campos.");
    return;
  }

  // Obtener el session_id desde sessionStorage
  let sessionID = sessionStorage.getItem('session_id');  // Asegúrate de que session_id está en sessionStorage
  if (!sessionID) {
    alert("No se encontró la sesión.");
    return;
  }

  let url1 = 'cgi-bin/new.pl?title=' + encodeURIComponent(title) + '&text=' + encodeURIComponent(texto);
  let url3 = '&owner=' + encodeURIComponent(userKey) + '&session_id=' + encodeURIComponent(sessionID);
  let urlcomple = url1 + url3;
  console.log(urlcomple);

  fetch(urlcomple)
    .then(response => response.text())
    .then(data => {
      let response = (new window.DOMParser()).parseFromString(data, "text/xml");
      responseNew(response);
    })
    .catch(error => {
      console.log('Error:', error);
    });
}

/*
 * Esta función obtiene los datos del artículo que se envían como respuesta
 * desde el CGI new.pl y los muestra en el HTML o un mensaje de error si
 * correspondiera
 */
function responseNew(response) {
  console.log("function responseNew", response);
  
  let articulo = response.getElementsByTagName('title');
  let texto = response.getElementsByTagName('text');
  
  if (articulo.length > 0 && texto.length > 0) {
    let title = articulo[0].textContent.trim();
    let textContent = texto[0].textContent.trim();
    
    if (title.length > 0 && textContent.length > 0) {
      let cuerpohtml = `
        <h1>${title}</h1>
        <p>${textContent}</p>
      `;
      document.getElementById('main').innerHTML = cuerpohtml;
    } else {
      console.log("Datos del artículo están vacíos.");
      document.getElementById('main').innerHTML = "<p>Error, usuario no existe o no llenó todos los campos correctamente.</p>";
    }
  } else {
    console.log("No se encontraron los elementos en la respuesta.");
    document.getElementById('main').innerHTML = "<p>Error, usuario no existe o no llenó todos los campos.</p>";
  }
}

/*
 * Esta función invoca al CGI view.pl, la respuesta del CGI debe ser
 * atendida por responseView
 */
function doView(owner, title) {
  console.log('se va a visualizar');
  let sessionId = sessionStorage.getItem('session_id');
  if (!sessionId) {
    showLogin();
    //sessionId = 'some_unique_session_id'; // Esto podría ser generado o asignado de otra forma
    //sessionStorage.setItem('session_id', sessionId); // Guardarlo en sessionStorage para futuras peticiones
  }
  let url = `cgi-bin/view.pl?owner=${encodeURIComponent(owner)}&title=${encodeURIComponent(title)}&session_id=${encodeURIComponent(sessionId)}`;
  console.log("La URL es ", url);

  let promise = fetch(url);
  promise.then(response => response.text()).then(data => {
    console.log("esto sale", data);
    responseView(data);
  }).catch(error => {
    console.log('Error:', error);
  });
}
/*
 * Esta función muestra la respuesta del cgi view.pl en el HTML o 
 * un mensaje de error en caso de algún problema.
 * nuevooo
 */
function responseView(response){
  console.log("esta data ha pasado",response);  /*Se tien un objto html traducito*/
  /*let body = response.getElementsByTagName('body'); /*Se hizo pruebas en consola*/
  /*let tagshtml = body[0].childNodes;  /*esto es un arry de todos los tags de body*/
  /*console.log("estos son lso tags de body", tagshtml);
  let nuevoMain = "";
  for (var i=0;i<tagshtml.length;i++){
    nuevoMain += tagshtml[i].outerHTML+"\n";
  }
  console.log("nuevoMain",nuevoMain);*/
  document.getElementById('main').innerHTML = response ;
}
/*
 * Esta función invoca al CGI delete.pl recibe los datos del artículo a 
 * borrar como argumentos, la respuesta del CGI debe ser atendida por doList
 */
function doDelete(owner, title){
  let sessionId = sessionStorage.getItem('session_id');
  console.log('se va a eliminar',owner,title,sessionId);
  let url = 'cgi-bin/delete.pl?owner='+owner+'&title='+title+'&session_id='+sessionId;
  console.log("la url es ",url);
  var xml;
  let promise = fetch(url);
  promise.then(response=>response.text()).then(data=>
    {
      xml = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("esto se eliminar",xml);
      doList() ;
    }).catch(error=>{
      console.log('Error :', error);
    });
}
/*
 * Esta función recibe los datos del articulo a editar e invoca al cgi
 * article.pl la respuesta del CGI es procesada por responseEdit
 */
function doEdit(owner, title){
  console.log('se va a editarA;',owner,title);
  let sessionId = sessionStorage.getItem('session_id');
  if (!sessionId) {
    showLogin();  // Función para redirigir a la página de inicio de sesión
    return;
  }
  let url = 'cgi-bin/article.pl?owner='+owner+'&title='+title+'&session_id='+sessionId;
  console.log("la url es ",url);
  let promise = fetch(url);
  promise.then(response => response.text()).then(data => {
    let xml = (new window.DOMParser()).parseFromString(data, "text/xml");
    console.log("Esto sale", xml);
    responseEdit(xml);  // Llamar a la función de respuesta de edición
  }).catch(error => {
    console.log('Error:', error);
  });
}
/*
 * Esta función recibe la respuesta del CGI data.pl y muestra el formulario 
 * de edición con los datos llenos y dos botones:
 * - Actualizar que invoca a doUpdate
 * - Cancelar que invoca a doList
 */
function responseEdit(xml){
  console.log ("son tres tags owner, title, text");
  console.log("vamos a editar",xml);
  let articles = xml.getElementsByTagName('article');   /*solo hay un articulo, se guarda en array*/
  let hojasxml= articles[0].childNodes;           /*obtengo todas las hojas de <article>*/
  console.log(hojasxml.length);
  let owner = hojasxml[1].textContent;        /*los espacios son considerados un nodos*/
  let title = hojasxml[3].textContent;
  let texto =hojasxml[5].textContent;             /*los numeros impares seria los nodos con text*/
  console.log("orden de las hojas",owner,title,texto);

  var formhtml = "";
  formhtml += `
    <form onsubmit="doUpdate('` + title + `'); return false;">
      <h1>` + title + `</h1><br>
      <label>Texto</label>
      <textarea id="cuadrotext" name="texto" style="width:100%; height:150px; padding: 10px;">` + texto + `</textarea><br>
      <button type="submit">Actualizar</button>
      <button type="button" onclick="doList()">Cancelar</button>
    </form>
  `;
  document.getElementById('main').innerHTML = formhtml;
}
/*
 * Esta función recibe el título del artículo y con la variable userKey y 
 * lo llenado en el formulario, invoca a update.pl
 * La respuesta del CGI debe ser atendida por responseNew
 */
function doUpdate(title){
  let texto = document.getElementById('cuadrotext').value;
  console.log("es el texto a actualizar", texto);
  let sessionId = sessionStorage.getItem('session_id');
  if (!sessionId) {
    showLogin();  // Redirigir a iniciar sesión si no existe el session_id
    return;
  }
  let url1 = 'cgi-bin/update.pl?title=' + encodeURIComponent(title) + '&text=';
  let textoencode = encodeURIComponent(texto);  // Asegúrate de que los saltos de línea y caracteres especiales estén bien codificados
  let url3 = `&owner=${encodeURIComponent(userKey)}&session_id=${encodeURIComponent(sessionId)}`;
  let urlcomple = url1 + textoencode + url3;
  
  // Depuración: Imprime la URL completa antes de enviarla
  console.log("URL completa antes de enviar:", urlcomple);
  
  var response;
  let promise = fetch(urlcomple);
  promise.then(response => response.text())
    .then(data => {
      response = (new window.DOMParser()).parseFromString(data, "text/xml");
      console.log("Respuesta del servidor:", response);
      responseNew(response);  // Procesar la respuesta en responseNew
    })
    .catch(error => {
      console.log('Error:', error);
    });
}

