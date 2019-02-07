﻿using System;
using System.Xml;
using log4net;
using log4net.Appender;
using log4net.Config;
using log4net.Core;

namespace OctopusTools.Diagnostics
{
    public static class Logger
    {
        const string LoggingConfiguration =
            @"<log4net>
  <root>
    <level value='DEBUG' />
    <appender-ref ref='TraceAppender' />
    <appender-ref ref='ConsoleAppender' />
  </root>

  <logger name='Octopus'>
    <level value='DEBUG' />
  </logger>
 
  <!-- For unit tests -->
  <appender name='TraceAppender' type='log4net.Appender.TraceAppender'>
    <layout type='log4net.Layout.PatternLayout'>
      <conversionPattern value='%message%newline' />
    </layout>
  </appender>

  <!-- When running interactively -->
  <appender name='ConsoleAppender' type='log4net.Appender.ColoredConsoleAppender'>
    <mapping>
      <level value='ERROR' />
      <foreColor value='Red, HighIntensity' />
    </mapping>
    <mapping>
      <level value='WARN' />
      <foreColor value='Yellow, HighIntensity' />
    </mapping>
    <mapping>
      <level value='Info' />
      <foreColor value='White, HighIntensity' />
    </mapping>
    <mapping>
      <level value='Debug' />
      <foreColor value='White' />
    </mapping>
    <layout type='log4net.Layout.PatternLayout'>
      <conversionPattern value='%message%newline' />
    </layout>
  </appender>
</log4net>";

        public static ILog Default
        {
            get { return Nested.Log; }
        }

        public static void SetLevel(this ILoggerWrapper log, string levelName)
        {
            var logger = (log4net.Repository.Hierarchy.Logger) log.Logger;
            logger.Level = logger.Hierarchy.LevelMap[levelName];
        }

        public static void AddAppender(this ILoggerWrapper log, IAppender appender)
        {
            var logger = (log4net.Repository.Hierarchy.Logger) log.Logger;
            logger.AddAppender(appender);
        }

        #region Nested type: Nested

        static class Nested
        {
            public static readonly ILog Log;

            static Nested()
            {
                var document = new XmlDocument();
                document.LoadXml(LoggingConfiguration);

                Log = LogManager.GetLogger("Octopus");
                XmlConfigurator.Configure(Log.Logger.Repository, (XmlElement) document.GetElementsByTagName("log4net")[0]);
            }
        }

        #endregion
    }
}