<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm3.aspx.cs" Inherits="EV_ford.WebForm3" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Intégration de la Recherche de Lieux Google Maps</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@700&display=swap" rel="stylesheet">
    <style>
        body, html {
            margin: 0;
            height: 100%;
            font-family: 'Poppins', sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .header {
            width: 100%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 20px;
            background-color: rgb(72, 72, 109);
            color: #faf8f8;
            box-shadow: 0 2px 4px 0 rgba(0,0,0,0.1);
            position: fixed;
            top: 0;
            z-index: 1000;
        }
        .header .logo {
            font-size: 24px;
            font-style: italic;
            margin: 0 auto;
        }
        .content {
            flex-grow: 1;
            width: 100%;
            display: flex;
            justify-content: center;
            align-items: center;
            padding-top: 100px;
        }
        .journey-planner {
            background: rgba(239, 240, 241, 0.9);
            border-radius: 10px;
            color: rgb(12, 2, 2);
            padding: 20px;
            box-shadow: 0 4px 8px rgba(243, 242, 242, 0.2);
            width: 340px;
            margin: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
        }
        .form-group input[type="text"], .form-group input[type="number"], .form-group select {
            width: calc(100% - 20px); /* Adjusted width */
            padding: 10px;
            border: 1px solid #ccc; /* Added border */
            border-radius: 5px;
            margin-bottom: 15px;
            background: #f3f0f0;
            color: rgb(14, 2, 2);
        }
        .form-group button {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 5px;
            background: #0e0909;
            color: white;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .form-group button:hover {
            background: #c0392b;
        }
        .background-image {
            background-image: url('backgroundddd.jpg');
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
        }
    </style>
</head>
<body>
    <div class="background-image"></div>
    <div class="header">
        <div class="logo"> <em style="font-size: 30px;">EVC</em></div>
    </div>
    <div class="content">
        <div class="journey-planner">
            <div class="form-group">
                <label for="location">Home</label>
                <input id="location" type="text" placeholder="Votre localisation actuelle">
            </div>
            <div class="form-group">
                <label for="destination">Destination</label>
                <input id="destination" type="text" placeholder="Destination">
            </div>
            <div class="form-group">
                <label for="startingCharge">État de charge (%)</label>
                <input id="startingCharge" type="number" placeholder="0 - 100" min="0" max="100">
            </div>
            <div class="container">
            
                
                <label for="model">Select Model:</label>
                <select id="model">
                  <option value="f150Lightning">F-150 Lightning (Extended Range)</option>
                  <option value="mustangMachE">Mustang Mach-E (Extended Range)</option>
                  <option value="escapePlugInHybrid">Escape Plug-In Hybrid</option>
                  <option value="maverickHybrid">Maverick Hybrid</option>
                  <option value="f150Hybrid">F-150 Hybrid</option>
                  <option value="explorerLimited">Explorer Limited Hybrid</option>
                  <option value="etransit">E-Transit</option>
                </select>
                
                <label for="distance">Distance to Travel (km):</label>
                <input type="number" id="distance" required>
                
            
                
                <button onclick="calculateChargingTime()">Calculate Charging Time</button>
                
                <p id="result"></p>
              </div>

            <div class="form-group">
                <button id="btnPlanJourney">Let's Go !</button>
            </div>
        </div>
    </div>
    <script src="https://polyfill.io/v3/polyfill.min.js?features=default"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const chargeStateInput = document.getElementById('startingCharge');
            chargeStateInput.addEventListener('keydown', function (event) {
                // Allow specific control keys to be used (backspace, tab, etc.)
                const allowedKeys = [46, 8, 9, 27, 13, 110, 190];
                if (allowedKeys.includes(event.keyCode) ||
                    // Allow: Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
                    (event.ctrlKey === true && (event.keyCode === 65 || event.keyCode === 67 || event.keyCode === 86 || event.keyCode === 88)) ||
                    // Allow: command+A, command+C, command+V, command+X (Mac)
                    (event.metaKey === true && (event.keyCode === 65 || event.keyCode === 67 || event.keyCode === 86 || event.keyCode === 88)) ||
                    // Allow: navigation keys (home, end, left, right)
                    (event.keyCode >= 35 && event.keyCode <= 39)) {
                    return;
                }
                // Prevent default if it's not a number or if the result would be greater than 100
                if ((event.shiftKey || (event.keyCode < 48 || event.keyCode > 57)) && (event.keyCode < 96 || event.keyCode > 105) ||
                    parseInt(this.value + event.key) > 100) {
                    event.preventDefault();
                }
            });

            initAutocomplete();
        });

        function initAutocomplete() {
            const locationInput = document.getElementById('location');
            const destinationInput = document.getElementById('destination');

            const autocompleteDestination = new google.maps.places.Autocomplete(destinationInput);
            autocompleteDestination.addListener('place_changed', function () {
                const place = autocompleteDestination.getPlace();
                console.log(place.name);
            });

            if (navigator.geolocation) {
                navigator.geolocation.getCurrentPosition(function (position) {
                    const geocoder = new google.maps.Geocoder();
                    const latlng = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude
                    };
                    geocoder.geocode({ 'location': latlng }, function (results, status) {
                        if (status === 'OK' && results[0]) {
                            locationInput.value = results[0].formatted_address;
                        }
                    });
                }, function (error) {
                    console.error("Geolocation failed: " + error.message);
                });
            }
        }
    </script>
<script>
    function calculateChargingTime() {
        const model = document.getElementById('model').value;
        const distance = parseFloat(document.getElementById('distance').value);
        const startingCharge = parseFloat(document.getElementById('startingCharge').value);

        const vehicles = {
            f150Lightning: { rangeKm: 515, chargingRateKmPerHour: 390 },
            mustangMachE: { rangeKm: 483, chargingRateKmPerHour: 390 },
            escapePlugInHybrid: { rangeKm: 59, chargingRateKmPerHour: 22 },
            maverickHybrid: { rangeKm: 800, chargingRateKmPerHour: 0 },
            f150Hybrid: { rangeKm: 1126, chargingRateKmPerHour: 0 },
            explorerLimited: { rangeKm: 756, chargingRateKmPerHour: 0 },
            etransit: { rangeKm: 193, chargingRateKmPerHour: 108 },
        };

        const vehicle = vehicles[model];
        if (!vehicle) {
            document.getElementById('result').innerText = "Please select a valid model.";
            return;
        }

        const rangeAvailableAtStartKm = vehicle.rangeKm * (startingCharge / 100);
        const additionalRangeNeededKm = Math.max(0, distance - rangeAvailableAtStartKm);
        const chargingTimeHours = additionalRangeNeededKm / vehicle.chargingRateKmPerHour;

        let resultText = Estimated Charging Time: ${ chargingTimeHours.toFixed(2)
    } hours;
    if (vehicle.chargingRateKmPerHour === 0 || isNaN(chargingTimeHours)) {
        resultText = "This model does not support fast charging. Please ensure you have enough fuel or charge for your trip.";
    }

    document.getElementById('result').innerText = resultText;
    }
    </script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAabJVSPSjilACr2BG2nX0LetukuSVnuyc&libraries=places&callback=initAutocomplete" async defer></script>
</body>
</html>
