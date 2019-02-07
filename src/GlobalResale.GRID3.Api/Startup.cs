using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using AutoMapper;
using FluentNHibernate.Cfg;
using GlobalResale.GRID3.Api.Infrastructure;
using GlobalResale.GRID3.Core.Domain;
using MediatR;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Tokens;
using Swashbuckle.AspNetCore.Swagger;

namespace GlobalResale.GRID3.Api
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Register the Swagger generator, defining 1 or more Swagger documents
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new Info
                {
                    Title = "GRID 3.0 API",
                    Version = "v1",
                    License = new License
                    {
                        Name = "Simpat Tech",
                        Url = "https://simpat.tech/"
                    }
                });
                var security = new Dictionary<string, IEnumerable<string>>
                {
                    {"Bearer", new string[] { }},
                };
                c.AddSecurityDefinition("Bearer", new ApiKeyScheme
                {
                    Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
                    Name = "Authorization",
                    In = "header",
                    Type = "apiKey"
                });
                c.AddSecurityRequirement(security);
            });

            services.Configure<JwtSettings>(Configuration.GetSection("JwtSettings"));

            services.AddMediatR();
            services.AddAutoMapper();

            services.AddSingleton(provider =>
            {
                return Fluently
                    .Configure()
                    .Database(() =>
                    {
                        return FluentNHibernate.Cfg.Db.MsSqlConfiguration
                            .MsSql2012
                            .ShowSql()
                            .ConnectionString(ConfigurationManager.ConnectionStrings["DefaultConnection"].ConnectionString);
                    })
                    .Mappings(m => m.FluentMappings.AddFromAssemblyOf<PersistentObjectMap>())
                    .BuildSessionFactory();
            });

            services.AddScoped(provider =>
                provider
                    .GetService<NHibernate.ISessionFactory>()
                    .OpenSession()
            );

            var sharedKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Configuration.GetSection("JwtSettings")["JwtKey"]));
            var issuerAudience = Configuration.GetSection("JwtSettings")["Domain"];

            services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
                .AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = new TokenValidationParameters
                    {

                        ValidateLifetime = true,
                        ValidateIssuerSigningKey = true,
                        ValidateIssuer = true,
                        ValidateAudience = true,
                        ValidIssuer = issuerAudience,
                        ValidAudience = issuerAudience,
                        IssuerSigningKey = sharedKey
                    };
                });

            services.AddHttpContextAccessor();
            services.AddMvc().SetCompatibilityVersion(CompatibilityVersion.Version_2_1);
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env)
        {
            app.UseSwagger();
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "GRID 3.0");
                c.RoutePrefix = string.Empty;
            });

            app.UseAuthentication();
            app.UseMvc();
        }
    }
}
