var assistant = angular.module('assistant', ['ngRoute']);

assistant.directive(
    'convertToNumber', 
    function() {
        return {
            require: 'ngModel',
            link: function(scope, element, attrs, ngModel) {
                ngModel.$parsers.push(function(val) {
                    return parseInt(val, 10);
                });
                ngModel.$formatters.push(function(val) {
                    return '' + val;
                });
            }
        };
    }
);
assistant.directive(
    'noBlur',
    function() {
        return {
            restrict: 'A',
            link: function(scope, element) {
                element.on('click', function() {
                    element[0].blur();
                });
            }
        }
    }
);

assistant.config(
    function($routeProvider) {
        $routeProvider
            .when('/', {
                redirectTo: '/about'
            })
            .when('/about', {
                templateUrl : 'pages/about.html',
                controller: 'aboutController'
            })
            .when('/primary', {
                redirectTo : '/primary/thermocouple'
            })
            .when('/primary/thermocouple', {
                templateUrl : 'pages/thermocouple.html',
                controller: 'pr1Controller'
            })
            .when('/primary/thermometr', {
                templateUrl : 'pages/thermometr.html',
                controller: 'pr2Controller'
            })
            .when('/secondary', {
                templateUrl : 'pages/secondary.html',
                controller: 'secController'
            })
            .otherwise({
                redirectTo: '/about/'
            })
    }
);

assistant.controller('headerController', function($scope, $location) {
    $scope.location = $location;
});
assistant.controller('aboutController', function($scope) {});

assistant.controller(
    'pr1Controller', 
    function($scope, $http) {
        $scope.show = false;
        $scope.form = {};
        $scope.grads = {}

        $scope.loadGrads = function() {
            $http.get("/api/grads/thermocouples/")
                .then(function(data) {
                    $scope.grads = data.data;
                });
        };

        

        $scope.loadGrads();
    }
);

assistant.controller(
    'pr2Controller', 
    function($scope, $http) {
        $scope.show = false;
        $scope.form = {};
        $scope.grads = {}

        $scope.calculate = function(url) {
            $http.post(url, $scope.form)
                .then(function(data) {
                    $scope.error = false;
                    $scope.show = true;
                    $scope.dt = data.data;
                }, function(data) {
                    $scope.show = false;
                    $scope.error = data;
                });
        };
    }
);

assistant.controller(
    'secController', 
    function($scope, $http) {
        $scope.show = false;
        $scope.form = {};
        $scope.grads = {}

        $scope.loadGrads = function() {
            $http.get("/api/grads/all/")
                .then(function(data) {
                    $scope.grads = data.data;
                });
        };

        $scope.calculate = function(url) {
            $http.post(url, $scope.form)
                .then(function(data) {
                    $scope.error = false;
                    $scope.show = true;
                    $scope.dt = data.data;
                }, function(data) {
                    $scope.show = false;
                    $scope.error = data;
                });
        };

        $scope.loadGrads();
    }
);

