const child_process = require('child_process');

module.exports = {
  name: 'pod-install',
  factory() {
    return {
      hooks: {
        afterAllInstalled(project, options) {
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

          const bundleResult = child_process.spawnSync('bundle', ['install'], {
            cwd: `${project.cwd}/example`,
            env: process.env,
            stdio: 'inherit',
            encoding: 'utf-8',
            shell: true,
          });

          if (bundleResult.status !== 0) {
            throw new Error('Failed to run bundle install: ', bundleResult);
          } else {
            console.log('✅ Run bunlde install successfully');
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
          } else {
            console.log('✅ Run pod-install successfully');
          }
        },
      },
    };
  },
};
