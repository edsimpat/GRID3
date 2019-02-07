module.exports = function(grunt) {

    grunt.initConfig({
        
        pkg: grunt.file.readJSON('package.json'),
    
        sass: {
            devUI: {
                options: {
                    style: 'expanded'
                },
                files: {
                    'src/UI/wwwroot/css/style.css': 'src/UI/wwwroot/css/style.scss'                    
                }
            },
            ciUI: {
                options: {
                    style: 'compressed'
                },
                files: {
                    'src/UI/wwwroot/css/style.css': 'src/UI/wwwroot/css/style.scss'
                }
            }
        },

        jshint: {
            src: ['src/**/*.js', '!src/**/lib/*.js']
        },
        
        clean: {
            docs: 'docs'
        },
        
        useminPrepare: {
            html: 'src/UI/Features/Shared/_Layout.cshtml'
        },
        
        usemin: {
            html: ['src/UI/Features/Shared/_Layout.cshtml'],
            css: ['src/UI/Features/Shared/_Layout.cshtml']
        },

        cssmin: {
            combine: {
                files: {
                    'src/UI/wwwroot/css/all.min.css': [
                        'src/UI/wwwroot/css/lib/*.css',
                        'src/UI/wwwroot/lib/**/*.css',
                        'src/UI/wwwroot/css/style.css'
                    ]
                }
            }
        }
    });
    
    // Tasks

    grunt.registerTask('dev', ['jshint', 'sass:devUI']);
    grunt.registerTask('ci', ['jshint', 'sass:ciUI', 'cssmin', 'usemin']);
    
    grunt.registerTask('default', ['clean']);
    
    // Task Dependencies
    
    grunt.loadNpmTasks('grunt-contrib-jshint');
    grunt.loadNpmTasks('grunt-contrib-clean');
    grunt.loadNpmTasks('grunt-contrib-cssmin');
    grunt.loadNpmTasks('grunt-contrib-sass');    
    grunt.loadNpmTasks('grunt-notify');    
    grunt.loadNpmTasks('grunt-usemin');
    
};