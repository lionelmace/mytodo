
var todoController = angular.module('todoController', [])

// inject the Todo service factory into our controller
todoController.controller('todoCtrl', ['$scope', '$http', 'todos', function ($scope, $http, todos) {
  $scope.formData = {};
  $scope.loading = true;

  // GET ============================================================
  // when landing on the page, get all todos and show them
  // use the service to get all the todos
  todos.get()
    .success(function (data) {
      $scope.todos = data;
      $scope.loading = false;
    });

  // ADD ============================================================
  // when submitting the add form, send the text to the node API
  $scope.addTodo = function () {

    // validate the formData to make sure that something is there
    // if form is empty, nothing will happen
    if ($scope.formData.text != undefined) {
      $scope.loading = true;

      // call the create function from our service (returns a promise object)
      todos.create($scope.formData)

      // if successful creation, call our get function to get all the new todos
      .success(function (data) {
        $scope.loading = false;
        $scope.formData = {}; // clear the form so our user is ready to enter another
        $scope.todos = data; // assign our new list of todos
      });
    }
  };

  // DELETE =========================================================
  // delete a todo after checking it
  $scope.deleteTodo = function (todo) {
    $scope.loading = true;

    todos.delete(todo)
      // if successful creation, call get function to get all new todos
      .success(function (data) {
        $scope.loading = false;
        $scope.todos = data; // assign our new list of todos
      });
  }
}]);
