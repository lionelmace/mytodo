var todoApp = angular.module('todoApp', [
  // Module dependencies
  'todoController', 'todoService'
]);

// Déclaration de l'application demoApp
var demoApp = angular.module('newTodoApp', [
  // Dépendances du "module"
  'todoList', 'todoService'
]);
