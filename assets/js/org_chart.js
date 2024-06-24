function transformApiDataToChartData(apiData) {
    const nodes = [];
    const dataLinks = [];

    // Define colors for levels
    const mainColor = '#4673c7'; // Blue for main incoming
    const floorColor = '#5ba775'; // Green for floors
    const deviceColor = '#c0c0c0'; // Grey for devices

    // Add the main incoming source manually with just the name for display
    nodes.push({
        id: 'Main Incoming',
        name: 'Main Incoming', // Use 'name' for display
        color: mainColor
    });

    // Iterate over each floor in the API data
    Object.entries(apiData).forEach(([floorName, devices]) => {
        // Add the floor with just the name for display
        nodes.push({
            id: floorName,
            name: floorName, // Use 'name' for display
            color: floorColor
        });
        // Connect floor to main incoming source
        dataLinks.push(['Main Incoming', floorName]);

        // Iterate over each device within the floor
        Object.entries(devices).forEach(([deviceName, deviceDetails]) => {
            if (deviceDetails && typeof deviceDetails === 'object' && deviceName !== 'Name' && deviceName !== 'Power' && deviceName !== 'Current' && deviceName !== 'Voltage' && deviceName !== 'PowerFactor') {
                // Add the device with just the name for display
                const deviceId = `${floorName}-${deviceName}`;
                nodes.push({
                    id: deviceId,
                    name: deviceDetails.Name[0], // Use 'name' for display
                    color: deviceColor
                });
                // Connect device to its floor
                dataLinks.push([floorName, deviceId]);
            }
        });
    });

    return { data: dataLinks, nodes };
}


function initializeOrgChart(apiData) {
    const { data, nodes } = transformApiDataToChartData(apiData);

    Highcharts.chart('container', {
        chart: {
            height: '200%', // Set height to 100% to fill the container
            inverted: false // Ensures vertical layout. For vertical orientation, keep this false.
        },
        title: {
            text: ''
        },
        series: [{
            type: 'organization',
            name: 'Building',
            keys: ['from', 'to'],
            data: data,
            nodes: nodes,
            borderColor: 'white',
            nodeWidth: 65
        }],
        tooltip: {
            outside: true
        },
        exporting: {
            allowHTML: true,
            sourceWidth: 800,
            sourceHeight: 600
        }
    });
}





