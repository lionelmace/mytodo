var todoService = angular.module('todoService', [])

// super simple service
// each function returns a promise object 
todoService.factory('todos', ['$http', function ($http) {
  return {
    get: function () {
      return $http.get('/api/todos');
    },
    create: function (todoData) {
      //LMA return $http.put('/api/todos', todoData);
      return $http.post('/api/todos', todoData);
    },
    delete: function (todo) {
      return $http.delete('/api/todos/' + todo.id);
    }
  }
}]);
