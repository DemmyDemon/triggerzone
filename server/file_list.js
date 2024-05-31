const fs = require('fs');

exports('GetZoneFilenames', (resource) => {
    if (!resource) {
        resource = GetInvokingResource()
    }
    let fullPath = GetResourcePath(resource) + '/zones/';
    let files = [];
    if (fs.existsSync(fullPath)){
        var raw = fs.readdirSync(fullPath);
        for (let fileNumber in raw){
            let fileName = raw[fileNumber];
            if (fileName.toLowerCase().endsWith("\.tzf")){
                files.push(fileName)
            }
        }
    }
    return files
});
