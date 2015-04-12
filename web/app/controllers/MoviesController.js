(function() {
    
    var MoviesController = function ($scope, $log, $window, $ocLazyLoad, customersFactory, appSettings, $compile) {
        $scope.sortBy = 'name';
        $scope.reverse = false;
        $scope.customers = [];
        $scope.appSettings = appSettings;
        
        $ocLazyLoad.load("scripts/ui-bootstrap-pagination-tpls-0.12.1.js").then(function() {
            var elToAppend;
            elToAppend = $compile('<pagination total-items="totalItems" ng-model="currentPage" items-per-page="itemsPerPage" max-size="maxSize" ng-change="pageChanged()" ng-hide="totalItems<=6"></pagination>')($scope);
            document.getElementById('paginationBar').appendChild(elToAppend[0]);
            console.log('Pagination Directive Lazy loaded.');
        }, function(err) {
            console.error(err);
        })
        
        //Angular bootstrap pagination
        //ref:https://angular-ui.github.io/bootstrap/
        $scope.totalItems = 0;
        $scope.currentPage = 1; //pagination is 1 baseed.
        $scope.itemsPerPage = 6;
        $scope.maxSize = 10;
        $scope.searchStr = '';
        $scope.posterImg = 'images/noPoster.jpg';
        $scope.posterImgAlt = 'No Poster Availabe';
        $scope.sortBy = 'film_id';
        $scope.reverse = false;
        
        $scope.setPage = function (pageNo) {
            $scope.currentPage = pageNo;
        };

        $scope.pageChanged = function() {
            $log.log('Page changed to: ' + $scope.currentPage);
            getMoviesXHR();
        };
        // end pagination.
        
        //Table Sort:
        $scope.doSort = function(colName) {
           $scope.sortBy = colName;
           $scope.reverse = !$scope.reverse;
           console.log('Sort By: ',$scope.sortBy);    
        };
        
        //Search
        //Note this is called on the first $digest loop during the bootstrap(ng) phase.
        $scope.$watch(
        function(){return $scope.searchStr;}, 
        function(newVal, oldVal) {getMoviesXHR();}
    );
                
        var getMoviesXHR = function(){
            customersFactory.getMovies($scope.currentPage,$scope.itemsPerPage,$scope.searchStr)
                .success(function(movies) {
                    $scope.totalItems = movies.resultSet;
                    $scope.movies = movies.dataSet.ROWS;
                })
                .error(function(data, status, headers, config) {
                    $log.log('Http Ajax Error :',data, status, headers, config);
                });
        };
            
        $scope.doSort = function(propName) {
           $scope.sortBy = propName;
           $scope.reverse = !$scope.reverse;
        };
        
    };
    
    MoviesController.$inject = ['$scope', '$log', '$window', '$ocLazyLoad', 'customersFactory', 
                                   'appSettings','$compile'];

    angular.module('moviesApp').controller('MoviesController', MoviesController);
    
}());