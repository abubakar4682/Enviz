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





//// Adjust the jsOrgChartFunc or create a new function that directly uses the Highcharts configuration
//function jsOrgChartFunc() {
//    Highcharts.chart('container', {
//        chart: {
//            height: 600,
//            inverted: true
//        },
//        title: {
//            text: 'Highcharts Org Chart'
//        },
//        accessibility: {
//            point: {
//                descriptionFormat: '{add index 1}. {toNode.name}' +
//                    '{#if (ne toNode.name toNode.id)}, {toNode.id}{/if}, ' +
//                    'reports to {fromNode.id}'
//            }
//        },
//        series: [{
//            type: 'organization',
//            name: 'Highsoft',
//            keys: ['from', 'to'],
//            data: [
//                ['Shareholders', 'Board'],
//                ['Board', 'CEO'],
//                ['CEO', 'CTO'],
//                ['CEO', 'CPO'],
//                ['CEO', 'CSO'],
//                ['CEO', 'HR'],
//                ['CTO', 'Product'],
//                ['CTO', 'Web'],
//                ['CSO', 'Sales'],
//                ['HR', 'Market'],
//                ['CSO', 'Market'],
//                ['HR', 'Market'],
//                ['CTO', 'Market']
//            ],
//            levels: [{
//                level: 0,
//                color: 'silver',
//                dataLabels: {
//                    color: 'black'
//                },
//                height: 25
//            }, {
//                level: 1,
//                color: 'silver',
//                dataLabels: {
//                    color: 'black'
//                },
//                height: 25
//            }, {
//                level: 2,
//                color: '#980104'
//            }, {
//                level: 4,
//                color: '#359154'
//            }],
//            nodes: [{
//                id: 'Shareholders'
//            }, {
//                id: 'Board'
//            }, {
//                id: 'CEO',
//                title: 'CEO',
//                name: 'Atle Sivertsen',
//                image: 'https://wp-assets.highcharts.com/www-highcharts-com/blog/wp-content/uploads/2022/06/30081411/portrett-sorthvitt.jpg'
//            }, {
//                id: 'HR',
//                title: 'CFO',
//                name: 'Anne Jorunn Fjærestad',
//                color: '#007ad0',
//                image: 'https://wp-assets.highcharts.com/www-highcharts-com/blog/wp-content/uploads/2020/03/17131210/Highsoft_04045_.jpg'
//            }, {
//                id: 'CTO',
//                title: 'CTO',
//                name: 'Christer Vasseng',
//                image: 'https://wp-assets.highcharts.com/www-highcharts-com/blog/wp-content/uploads/2020/03/17131120/Highsoft_04074_.jpg'
//            }, {
//                id: 'CPO',
//                title: 'CPO',
//                name: 'Torstein Hønsi',
//                image: 'https://wp-assets.highcharts.com/www-highcharts-com/blog/wp-content/uploads/2020/03/17131213/Highsoft_03998_.jpg'
//            }, {
//                id: 'CSO',
//                title: 'CSO',
//                name: 'Anita Nesse',
//                image: 'https://wp-assets.highcharts.com/www-highcharts-com/blog/wp-content/uploads/2020/03/17131156/Highsoft_03834_.jpg'
//            }, {
//                id: 'Product',
//                name: 'Product developers'
//            }, {
//                id: 'Web',
//                name: 'Web devs, sys admin'
//            }, {
//                id: 'Sales',
//                name: 'Sales team'
//            }, {
//                id: 'Market',
//                name: 'Marketing team',
//                column: 5
//            }],
//            colorByPoint: false,
//            color: '#007ad0',
//            dataLabels: {
//                color: 'white'
//            },
//            borderColor: 'white',
//            nodeWidth: 'auto'
//        }],
//        tooltip: {
//            outside: true
//        },
//        exporting: {
//            allowHTML: true,
//            sourceWidth: 800,
//            sourceHeight: 600
//        }
//    });
//}
//``
