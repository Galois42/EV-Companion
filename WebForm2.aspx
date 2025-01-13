<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm2.aspx.cs" Inherits="EV_ford.WebForm2" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>EVC</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@700&display=swap" rel="stylesheet"/>
    <style>
        
        body, html {
            height: 100%;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
        }
        #header {
            background: #fffff;
            color: #080101;
            padding: 20px 20px;
            text-align: left; /* Aligner le texte au milieu */
            font-size: 30px;
            font-style: italic; /* Mettre le texte en italique */
            font-family: 'Poppins', sans-serif;
        }
        #container {
            display: flex;
            flex: 1;
            height: 0; /* This will be overridden by flex property */
        }
        #sidebar {
              width: 300px;
              background: #f2f2f2;
              padding: 20px;
              overflow: auto;
              display: flex; /* Use flexbox to align items */
              flex-direction: column; /* Stack items vertically */
              align-items: center; /* Center items horizontally */
              justify-content: center; /* Center items vertically if there is extra space */
        }
        #map {
            flex: 1;
            min-height: 500px; /* Minimum height for the map */
        }
    </style>
    <script src="https://polyfill.io/v3/polyfill.min.js?features=default"></script>
    <script src="formatted_coordinates.js"></script>
</head>
<body>
    <div id="header">EVC</div>
    <div id="container">
        <div id="sidebar"> <img src="bg.jpg" alt="Description de l'image" style="width: 100%; height: auto; display: block;"/>
            </div>
        <div id="map" style="height:500px;">Votre carte apparaîtra ici.</div>
        <div id="travel-time" style="padding: 10px; background: #fff; position: absolute; top: 10px; left: 50%; transform: translateX(-50%); z-index: 1;">
    <!-- Travel time will be displayed here -->
            </div>
            </div>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAabJVSPSjilACr2BG2nX0LetukuSVnuyc&libraries=places,geometry&callback=initMap&v=weekly" defer="defer"></script>
    <script>
        // The following example creates complex markers to indicate beaches near
        // Sydney, NSW, Australia. Note that the anchor is set to (0,32) to correspond
        // to the base of the flagpole.
        function initMap() {
            var home = '<%=Session["Home"]%>';
            var destination = '<%=Session["Destination"]%>';

            var map = new google.maps.Map(document.getElementById('map'), {
                zoom: 10,
                center: { lat: -34.397, lng: 150.644 }
            });

            var directionsService = new google.maps.DirectionsService();
            var directionsRenderer = new google.maps.DirectionsRenderer();
            directionsRenderer.setMap(map);

            calculateAndDisplayRoute(directionsService, directionsRenderer, home, destination, map);
        }

        function calculateAndDisplayRoute(directionsService, directionsRenderer, home, destination, map) {
            directionsService.route({
                origin: { query: home },
                destination: { query: destination },
                travelMode: 'DRIVING'
            }, function (response, status) {
                if (status === 'OK') {
                    directionsRenderer.setDirections(response);
                    optimizeChargingStationSearch(map, response.routes[0]);
                    var travelTime = response.routes[0].legs[0].duration.text;
                    displayTravelTime(travelTime);
                } else {
                    window.alert('Directions request failed due to ' + status);
                }
            });
        }
        function displayTravelTime(travelTime) {
            // Create a div element to display travel time or use an existing element by id
            var travelTimeElement = document.getElementById('travel-time');
            if (!travelTimeElement) {
                travelTimeElement = document.createElement('div');
                travelTimeElement.id = 'travel-time';
                document.body.appendChild(travelTimeElement);
            }

            // Update the content of the div element with the travel time
            travelTimeElement.innerHTML = '<span>🕒 ' + travelTime + '</span>';
        }
        function optimizeChargingStationSearch(map, route) {
            var path = route.overview_path; // Array of LatLng points along the route
            var searchIntervalMeters = 10000; // Define the interval for the search points (10 km)
            var minSearchRadius = 5000; // Minimum search radius (5 km)
            var nextPointIndex = 0; // Keeps track of the next point index on the path

            // Calculate the total length of the path to adjust the search interval accordingly
            var totalPathLength = 0;
            for (var i = 0; i < path.length - 1; i++) {
                totalPathLength += google.maps.geometry.spherical.computeDistanceBetween(path[i], path[i + 1]);
            }

            while (nextPointIndex < path.length - 1) {
                var startPoint = path[nextPointIndex];
                var cumulativeDistance = 0;
                var searchPoint;

                // Find the next point on the path at the specified interval distance
                while (cumulativeDistance < searchIntervalMeters && nextPointIndex < path.length - 1) {
                    nextPointIndex++;
                    cumulativeDistance += google.maps.geometry.spherical.computeDistanceBetween(startPoint, path[nextPointIndex]);
                }

                // If the cumulative distance is less than the interval, use the last point on the path
                if (cumulativeDistance < searchIntervalMeters) {
                    searchPoint = path[path.length - 1];
                } else {
                    // Calculate the actual search point using the interval distance
                    searchPoint = google.maps.geometry.spherical.computeOffset(startPoint, searchIntervalMeters, google.maps.geometry.spherical.computeHeading(startPoint, path[nextPointIndex]));
                }

                // Perform the search at the determined point
                searchEVStations(map, searchPoint, minSearchRadius);

                // If we've reached the last point, break out of the loop
                if (nextPointIndex >= path.length - 1) {
                    break;
                }
            }
        }

        function searchEVStations(map, point, radius) {
            var service = new google.maps.places.PlacesService(map);
            var request = {
                location: point,
                radius: radius,
                type: ['charging_station']
            };

            service.nearbySearch(request, function (results, status) {
                if (status === google.maps.places.PlacesServiceStatus.OK && results && results.length > 0) {
                    // Only create a marker for the first charging station found
                    createMarker(results[0], map);
                }
            });
        }

        function createMarker(place, map) {
            if (!place.geometry || !place.geometry.location) return;

            const marker = new google.maps.Marker({
                map: map,
                position: place.geometry.location,
                title: place.name
            });

            google.maps.event.addListener(marker, 'click', function () {
                var infowindow = new google.maps.InfoWindow({
                    content: '<div><strong>' + place.name + '</strong><br>' +
                        'Place ID: ' + place.place_id + '<br>' +
                        place.vicinity + '</div>'
                });
                infowindow.open(map, this);
            });
        }
        
        
        


        window.initMap = initMap;
    </script>
</body>
</html>