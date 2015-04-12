(function() {
    
    var app = angular.module('moviesApp', ['ui.router', 'ngAnimate','ui.bootstrap','oc.lazyLoad']);
    
    /*
    app.config(function($routeProvider) {
        $routeProvider
            .when('/', {
                controller: 'MoviesController',
                templateUrl: 'app/views/movies.html'
            })
            .otherwise( { redirectTo: '/' } );
    });
    */
    
    app.config(function ($stateProvider, $urlRouterProvider, $ocLazyLoadProvider) {
    //Redirect any unmatched url
    $urlRouterProvider.otherwise("/");
    
    //home
    $stateProvider.state('index', {
        url: "/",
        templateUrl: "app/views/movies.html",
        controller: "MoviesController",
        resolve: {
            deps: function ($ocLazyLoad) {
                return $ocLazyLoad.load('scripts/console.js');
            }
        }
    });
       

   $ocLazyLoadProvider.config({
      debug: true
    });

});
    
}());
