// js/todoList.js
'use strict';

// Declaration of todoController module
var todoController = angular.module('todoController', []);

// Application Controller of "Todo List"
todoController.controller('todoCtrl', ['$scope', '$http', 'todos', function ($scope, $http, todos)
{
    console.log('CTR - In Controller...');
    $scope.newTodo = '';
    $scope.loading = true;

    // GET ============================================================
    // when landing on the page, get all todos and show them
    // use the service to get all the todos
    todos.get()
    .success(function (data) {
      $scope.todos = data;
      $scope.loading = false;
    });

    // Add a new todo
    $scope.addTodo = function () {

      // .trim() enables to remove all useless spaces before and after a string
      //bug var newTodo = $scope.newTodo.trim();
      var newTodo = $scope.newTodo;
      console.log('CTR - Adding todo: ' + newTodo.text );
      if (!newTodo.text.length) {
        // éviter les todos vides
        return;
      }

      $scope.loading = true;

      // call the create function from our service (returns a promise object)
      todos.create($scope.newTodo)

      // if successful creation, call our get function to get all the new todos
      .success(function (data) {
        $scope.loading = false;
        $scope.newTodo = ''; // clear the form so our user is ready to enter another
        $scope.todos = data; // assign our new list of todos
      });
    };

    // Delete a todo
    $scope.deleteTodo = function (todo) {
      console.log('CTR - Deleting todo...');
      $scope.loading = true;

      todos.delete(todo)
        // if successful deletion, call get function to get all new todos
        .success(function (data) {
          $scope.loading = false;
          $scope.todos = data; // assign our new list of todos
        });
    }

    // Select or Deselect all todos
    $scope.markAll = function (completed) {
      console.log('CTR - Selecting all todos...');
      $scope.todos.forEach(function (todo) {
        todo.completed = completed;
      });
    };

    // Delete all selected todos
    $scope.clearCompletedTodos = function () {
      console.log('CTR - Deleting all selected todos...');
      $scope.todos.filter(function (todo) {
        //return !todo.completed;
        todos.delete(todo)
        // if successful deletion, call get function to get all new todos
        .success(function (data) {
          $scope.loading = false;
          $scope.todos = data; // assign our new list of todos
        });
      });
    };
    }
]);
