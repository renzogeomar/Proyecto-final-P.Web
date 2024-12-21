var userFullName = '';
var userKey = '';

window.addEventListener('load', showWelcome);
function showWelcome(){
  let html = '<h2>Bienvenido ' + userFullName + '</h2>\n';
  html += `
          <p>Este sistema fue desarrollado por alumnos del primer año de la Escuela Profesional de Ingeniería de Sistemas, de la Universidad Nacional de San Agustín de Arequipa</p>
          <p>El sistema fué desarrollado usando estas tecnologías:</p>
          <ul>
            <li>HTML y CSS</li>
            <li>Perl para el backend</li>
            <li>MariaDB para la base de datos</li>
            <li>Javascript para el frontend</li>
            <li>Las páginas se escriben en lenguaje Markdown</li>
            <li>Se usaron expresiones regulares para el procesamiento del lenguaje Markdown</li>
            <li>La comunicación entre el cliente y el servidor se hizo usando XML de manera asíncrona</li>
          </ul>`;
  document.getElementById('main').innerHTML = html;
}

function showMenuUserLogged() {
  let html = "<p onclick='showWelcome()'>Inicio</p>\n" +
    "<p onclick='doList()'>Lista de Páginas</p>\n" +
    "<p onclick='showNew()' class='rigthAlign'>Página Nueva</p>\n" +
    "<p onclick='doLogout()' class='rightAlign'>Cerrar Sesión</p>\n"; // Agregado botón de cierre de sesión
  document.getElementById('menu').innerHTML = html;
}

// Función para cerrar sesión
function doLogout() {
  // Recuperar el session_id del sessionStorage
  var session_id = sessionStorage.getItem('session_id');

  if (!session_id) {
    console.log('No hay sesión activa');
    showLogin(); // Si no hay session_id, redirigir a login
    return;
  }

  // Eliminar session_id del sessionStorage
  sessionStorage.removeItem('session_id');

  // Enviar el session_id al servidor para eliminarlo de la base de datos
  fetch('/cgi-bin/logout.pl', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: 'session_id=' + encodeURIComponent(session_id) // Enviar session_id como parte del cuerpo
  })
  .then(response => response.text())
  .then(data => {
    console.log(data);  // Ver la respuesta para verificar si la sesión se cerró correctamente
    showLogin();        // Volver a mostrar el formulario de login
  })
  .catch(error => {
    console.log('Error al cerrar sesión:', error);
    showLogin();        // En caso de error, mostrar login
  });
}

