var todoService = angular.module('todoService', [])

// each function returns a promise object 
todoService.factory('todos', ['$http', function ($http) {
  return {
    get: function () {
      return $http.get('api/todos');
    },
    create: function (todoData) {
      return $http.post('api/todos', todoData);
    },
    delete: function (todo) {
      return $http.delete('api/todos/' + todo.id);
    }
  }
}]);
