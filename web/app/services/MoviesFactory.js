(function() {
    var customersFactory = function($http) {
    
        var factory = {};
        
        factory.getMovies = function(page,returnSet,searchStr){
            page = page || 1;
            returnSet = returnSet || 50;
            searchStr = searchStr || '';
            
            var url = 'http://www.stevenbenjamin.com/assets/cfc/services.cfc?method=getMovies'
                +'&page=' + page
                +'&returnSet=' + returnSet 
                +'&searchStr=' + searchStr
                +'&token=dhd7dteg56533d'
                +'&callback=JSON_CALLBACK'
            
            return $http.jsonp(url,{timeout:6000});
        };
        
        return factory;
    };
    
    customersFactory.$inject = ['$http'];
        
    angular.module('moviesApp').factory('customersFactory', customersFactory);
                                           
}());