<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="EV_ford.WebForm1" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>EV  Planner</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@700&display=swap" rel="stylesheet"/>
    <style>
  body, html {
            margin: 0;
            height: 100%;
            font-family: 'Arial', sans-serif;
            background-image: url('background.jpeg'); /* Adjust your path */
            background-position: center;
            background-repeat: no-repeat;
            background-size: cover;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .header {
            width: 100%;
            display: flex;
            justify-content: center; /* Center align the header content */
            align-items: center;
            padding: 10px 20px;
            background-color: #ffffff;
            box-shadow: 0 2px 4px 0 rgba(0,0,0,0.1);
            position: fixed;
            top: 0;
            left: 0;
            z-index: 1000;
        }
        .header-left {
            font-family: 'Poppins', sans-serif;
            font-size: 24px;
            font-weight: 700;
            font-style: italic; /* Make text italic */
        }
        .header-right {
            display: flex;
            align-items: center;
        }
        .header-link {
            text-decoration: none;
            color: #333;
            padding: 8px 16px;
            margin-right: 10px;
            border-radius: 4px;
            transition: background-color 0.3s, color 0.3s;
        }
        .header-link:hover {
            background-color: #f5f5f5;
            color: #000;
        }
        .content {
            flex-grow: 1;
            width: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding-top: 60px; /* Adjust for header */
        }
        .journey-planner {
            background: rgba(44, 62, 80, 0.9);
            border-radius: 10px;
            color: white;
            padding: 20px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            width: 320px; /* Adjusted width for better alignment */
            margin-top: 20px;
            z-index: 10;
            display: flex;
            flex-direction: column;
            align-items: stretch; /* Ensure children align correctly */
        }
        .form-group {
            margin-bottom: 15px;
            display: flex;
            align-items: center; /* Align label and input */
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-size: 14px;
            color: white;
        }
        .form-group .icon {
            background: #34495e;
            padding: 10px;
            display: inline-block;
            border-radius: 5px 0 0 5px;
            color: #bdc3c7;
        }
        .form-group input[type="text"],
        .form-group select {
            flex: 1; /* Take up remaining space */
            padding: 10px;
            border: none;
            border-radius: 0 5px 5px 0; /* Adjusted radius for alignment */
            background: #34495e;
            color: white;
            margin-bottom: 0; /* Remove margin to fix alignment */
        }
        .form-group button {
            width: 100%;
            padding: 10px;
            border: none;
            border-radius: 5px;
            background: #e74c3c;
            color: white;
            cursor: pointer;
            transition: background 0.3s ease;
        }
        .form-group button:hover {
            background: #c0392b;
        }
    </style>
</head>
<body>
    <form runat="server"> <!-- Ajoutez cette ligne -->
        <div class="header">
            <div class="header-left">
                EVC<!-- Remplacez par le nom de votre site web -->
            </div>
     
        </div>
        <div class="content">
            <div class="journey-planner">
                <div class="form-group">
                    <label for="home">My location</label>
                    <div class="icon">&#8962;</div>
                    <asp:TextBox ID="txtHome" runat="server" CssClass="location-input" placeholder="Location"></asp:TextBox>
                </div>
                <div class="form-group">
                    <label for="destination">Destination</label>
                    <div class="icon">&#9873;</div>
                    <asp:TextBox ID="txtDestination" runat="server" CssClass="destination-input" placeholder="Destination"></asp:TextBox>
                </div>
                
                <div class="form-group">
                    <label for="startingCharge">(%)</label>
                    <asp:TextBox ID="txtStartingCharge" runat="server" CssClass="form-control" placeholder="0 - 100" TextMode="Number" min="0" max="100" />
                </div>
                
                
                <div class="form-group">
                    <label for="model">Select Model:</label>
                    <asp:DropDownList ID="ddlModel" runat="server" CssClass="form-control">
                        <asp:ListItem Text="F-150 Lightning (Extended Range)" Value="f150Lightning" />
                        <asp:ListItem Text="Mustang Mach-E (Extended Range)" Value="mustangMachE" />
                        <asp:ListItem Text="Escape Plug-In Hybrid" Value="escapePlugInHybrid" />
                                 <asp:ListItem Text="Maverick Hybrid" Value="maverickHybrid" />
                        <asp:ListItem Text="F-150 Hybrid" Value="f150Hybrid" />
<asp:ListItem Text="Explorer Limited Hybrid" Value="explorerLimited" />
<asp:ListItem Text="E-Transit" Value="etransit" />
                        
                    </asp:DropDownList>
                </div>
                
                
                <div class="form-group">
                    <label for="distance">Distance to Travel (km):</label>
                    <asp:TextBox ID="txtDistance" runat="server" CssClass="form-control" TextMode="Number" placeholder="500" />
                </div>
                
                
                <div class="form-group">
    <asp:Button ID="btnCalculateChargingTime" runat="server" Text="Calculate Charging Time" CssClass="form-control" OnClientClick="calculateChargingTime(); return false;" />
</div>
                <div id="result"></div>
                
                <div class="form-group">
                    <asp:Button ID="btnPlanJourney" runat="server" Text="Let's Go !" OnClick="btnPlanJourney_Click" CssClass="form-control" />
                </div>
            </div>
        </div>
    </form>

    
    <script src="https://polyfill.io/v3/polyfill.min.js?features=default"></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const chargeStateInput = document.getElementById('startingCharge');
            chargeStateInput.addEventListener('keydown', function (event) {
                // Allow specific control keys to be used (backspace, tab, etc.)
                const allowedKeys = [46, 8, 9, 27, 13, 110, 190];
                if (allowedKeys.includes(event.key) ||
                    // Allow: Ctrl+A, Ctrl+C, Ctrl+V, Ctrl+X
                    (event.ctrlKey === true && (event.key === 65 || event.key === 67 || event.key === 86 || event.key === 88)) ||
                    // Allow: command+A, command+C, command+V, command+X (Mac)
                    (event.metaKey === true && (event.key === 65 || event.key === 67 || event.key === 86 || event.key === 88)) ||
                    // Allow: navigation keys (home, end, left, right)
                    (event.key >= 35 && event.key <= 39)) {
                    return;
                }
                // Prevent default if it's not a number or if the result would be greater than 100
                if ((event.shiftKey || (event.key < 48 || event.key > 57)) && (event.key < 96 || event.key > 105) ||
                    parseInt(this.value + event.key) > 100) {
                    event.preventDefault();
                }
            });

            initAutocomplete();
        });

        function initAutocomplete() {
            const locationInput = document.querySelector('.location-input');
            const destinationInput = document.querySelector('.destination-input');

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
        const model = document.getElementById('ddlModel').value;
        const distance = parseFloat(document.getElementById('txtDistance').value);
        const startingCharge = parseFloat(document.getElementById('txtStartingCharge').value);

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

        let resultText;
        if (vehicle.chargingRateKmPerHour === 0 || isNaN(chargingTimeHours)) {
            resultText = "This model does not support fast charging. Please ensure you have enough fuel or charge for your trip.";
        } else {
            resultText = `Estimated Charging Time: ${chargingTimeHours.toFixed(2)} hours`;
        }

        document.getElementById('result').innerText = resultText;
    }
    </script>
    <script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAabJVSPSjilACr2BG2nX0LetukuSVnuyc&libraries=places&callback=initAutocomplete" async="async" defer="defer"></script>
</body>
</html>