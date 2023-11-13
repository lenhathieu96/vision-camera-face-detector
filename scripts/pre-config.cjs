const fs = require('fs');

const PACKAGE_JSON_PATH = 'package.json';

module.exports = {
  name: 'pre-config',
  factory() {
    return {
      hooks: {
        registerPackageExtensions(_, __) {
          // Read the package.json file
          const packageJSON = JSON.parse(
            fs.readFileSync(PACKAGE_JSON_PATH, 'utf-8')
          );

          if (!packageJSON.workspaces) {
            const workspaces = ['example'];
            // Update the package.json file
            packageJSON.workspaces = workspaces;

            // Write the updated package.json file
            fs.writeFileSync(
              PACKAGE_JSON_PATH,
              JSON.stringify(packageJSON, null, 2)
            );

            console.log('✅ Workspaces set successfully.');
          }
        },
      },
    };
  },
};
