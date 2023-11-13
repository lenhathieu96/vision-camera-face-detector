const fs = require('fs')
const child_process  =require('child_process')

const PACKAGE_JSON_PATH = 'package.json';


module.exports = {
  name: 'pod-install',
  factory() {
    return {
      hooks: {
        afterAllInstalled(project, options) {
          // Define workspaces
          const workspaces = ['example'];

          // Read the package.json file
          const packageJSON = JSON.parse(fs.readFileSync(PACKAGE_JSON_PATH, 'utf-8'));

          // Update the package.json file
          packageJSON.workspaces = workspaces;

          // Write the updated package.json file
          fs.writeFileSync(PACKAGE_JSON_PATH, JSON.stringify(packageJSON, null, 2));

          console.log('✅ Workspaces set successfully.');

          if (process.env.POD_INSTALL === '0') {
            return;
          }

          if (
            options &&
            (options.mode === 'update-lockfile' ||
              options.mode === 'skip-build')
          ) {
            return;
          }

          const bundleResult = child_process.spawnSync(
            'bundle',
            ['install'],
            {
              cwd: `${project.cwd}/example`,
              env: process.env,
              stdio: 'inherit',
              encoding: 'utf-8',
              shell: true,
            }
          );

          if (bundleResult.status !== 0) {
            throw new Error('Failed to run bundle install: ', bundleResult);
          }else {
            console.log('✅ Run bunlde install successfully')
          }

          const result = child_process.spawnSync(
            'yarn',
            ['pod-install', 'example/ios'],
            {
              cwd: project.cwd,
              env: process.env,
              stdio: 'inherit',
              encoding: 'utf-8',
              shell: true,
            }
          );

          if (result.status !== 0) {
            throw new Error('Failed to run pod-install: ', result);
          }else{
            console.log("✅ Run pod-install successfully")
          }

        
        },
      },
    };
  },
};
